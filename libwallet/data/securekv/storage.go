package securekv

import (
	"context"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/app_provided_data"
)

type SecureKeyValueStorage interface {
	Put(ctx context.Context, key string, value []byte) error
	Get(ctx context.Context, key string) (*Secret, error)
	Delete(ctx context.Context, key string) error
	Wipe(ctx context.Context) error
}

type secureKeyValueStorage struct {
	bridge app_provided_data.SecureKeyValueStorage
}

func NewSecureKeyValueStorage(
	bridge app_provided_data.SecureKeyValueStorage,
) SecureKeyValueStorage {
	return &secureKeyValueStorage{bridge: bridge}
}

func (s *secureKeyValueStorage) Put(_ context.Context, key string, value []byte) error {
	if key == "" {
		return newStorageFailedError(errors.Errorf("key must not be empty"))
	}
	if value == nil {
		return newStorageFailedError(errors.Errorf("value must not be nil"))
	}
	return classifyError(s.bridge.Put(key, value))
}

// Get returns a capability handle; the bridge is queried lazily by WithSecret.
// Errors from the bridge surface there, not here.
func (s *secureKeyValueStorage) Get(_ context.Context, key string) (*Secret, error) {
	if key == "" {
		return nil, newStorageFailedError(errors.Errorf("key must not be empty"))
	}
	return NewSecret(key, s.bridge), nil
}

func (s *secureKeyValueStorage) Delete(_ context.Context, key string) error {
	return classifyError(s.bridge.Delete(key))
}

func (s *secureKeyValueStorage) Wipe(_ context.Context) error {
	return classifyError(s.bridge.Wipe())
}
