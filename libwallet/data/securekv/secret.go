package securekv

import (
	"github.com/muun/libwallet/app_provided_data"
	"github.com/muun/libwallet/platform/preconditions"
)

// Secret holds no plaintext: bytes only exist inside WithSecret's callback.
type Secret struct {
	key     string
	fetcher app_provided_data.SecureKeyValueStorage
}

func NewSecret(key string, fetcher app_provided_data.SecureKeyValueStorage) *Secret {
	return &Secret{
		key:     preconditions.CheckNotEmpty(key),
		fetcher: preconditions.CheckNotNil(fetcher),
	}
}

// WithSecret fetches fresh on every call.
func (s *Secret) WithSecret(fn func([]byte) error) error {
	b, err := s.fetcher.Get(s.key)
	if err != nil {
		return classifyError(err)
	}
	defer wipeSecret(b)
	return fn(b)
}

// wipeSecret routes through observeBytes to defeat dead-store elimination.
// Best-effort: Go has no official secure-zeroize primitive.
func wipeSecret(b []byte) {
	for i := range b {
		b[i] = 0
	}
	_ = observeBytes(b)
}

// observeBytes is //go:noinline so the compiler must treat the call as
// opaque, keeping prior writes to b live.
//
//go:noinline
func observeBytes(b []byte) byte {
	var v byte
	for _, x := range b {
		v |= x
	}
	return v
}
