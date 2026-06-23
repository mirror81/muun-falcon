package securekv_test

import (
	"context"
	"testing"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/app_provided_data"
	"github.com/muun/libwallet/data/securekv"
)

type fakeBridge struct {
	getBytes []byte
	getErr   error
}

func newFakeBridge() *fakeBridge {
	return &fakeBridge{}
}

func (b *fakeBridge) Put(_ string, _ []byte) error {
	return nil
}

func (b *fakeBridge) Get(_ string) ([]byte, error) {
	if b.getErr != nil {
		return nil, b.getErr
	}
	if b.getBytes == nil {
		panic("fakeBridge.Get: no preset getBytes or getErr; tests must set one")
	}
	// Fresh copy each call so WithSecret's wipe does not affect later calls.
	return append([]byte(nil), b.getBytes...), nil
}

func (b *fakeBridge) Delete(_ string) error {
	panic("fakeBridge.Delete called but not exercised")
}

func (b *fakeBridge) Wipe() error {
	panic("fakeBridge.Wipe called but not exercised")
}

func TestSecureKeyValueStorage(t *testing.T) {
	ctx := context.Background()

	t.Run("error classification via WithSecret", func(t *testing.T) {
		testCases := []struct {
			desc      string
			bridgeErr error
			check     func(error) bool
		}{
			{
				"ErrCodeNotFound wraps as NotFoundError",
				errors.New(app_provided_data.ErrCodeNotFound + ": key missing"),
				func(err error) bool {
					var target *securekv.NotFoundError
					return errors.As(err, &target)
				},
			},
			{
				"ErrCodeDecryptionFailed wraps as DecryptionFailedError",
				errors.New(app_provided_data.ErrCodeDecryptionFailed + ": key invalidated"),
				func(err error) bool {
					var target *securekv.DecryptionFailedError
					return errors.As(err, &target)
				},
			},
			{
				"unknown error wraps as StorageFailedError",
				errors.New("disk full"),
				func(err error) bool {
					var target *securekv.StorageFailedError
					return errors.As(err, &target)
				},
			},
		}
		for _, tc := range testCases {
			t.Run(tc.desc, func(t *testing.T) {
				bridge := newFakeBridge()
				bridge.getErr = tc.bridgeErr
				storage := securekv.NewSecureKeyValueStorage(bridge)

				secret, err := storage.Get(ctx, "key")
				if err != nil {
					t.Fatalf("Get() error = %v, lazy Get must not fail", err)
				}
				err = secret.WithSecret(func(_ []byte) error {
					t.Fatal("fn should not be called when bridge errors")
					return nil
				})
				if err == nil {
					t.Fatal("expected error from WithSecret")
				}
				if !tc.check(err) {
					t.Fatalf("error type check failed: %v", err)
				}
			})
		}
	})

	t.Run("Get is lazy: no native call until WithSecret", func(t *testing.T) {
		bridge := newFakeBridge()
		// Neither getBytes nor getErr set: any bridge.Get call would panic.
		storage := securekv.NewSecureKeyValueStorage(bridge)

		_, err := storage.Get(ctx, "key")
		if err != nil {
			t.Fatalf("Get() error = %v, should not call bridge", err)
		}
	})

	t.Run("Get rejects empty key", func(t *testing.T) {
		bridge := newFakeBridge()
		storage := securekv.NewSecureKeyValueStorage(bridge)

		_, err := storage.Get(ctx, "")
		if err == nil {
			t.Fatal("expected error for empty key")
		}
	})

	t.Run("Put rejects empty key", func(t *testing.T) {
		bridge := newFakeBridge()
		storage := securekv.NewSecureKeyValueStorage(bridge)

		err := storage.Put(ctx, "", []byte("value"))
		if err == nil {
			t.Fatal("expected error for empty key")
		}
	})

	t.Run("Put rejects nil value", func(t *testing.T) {
		bridge := newFakeBridge()
		storage := securekv.NewSecureKeyValueStorage(bridge)

		err := storage.Put(ctx, "key", nil)
		if err == nil {
			t.Fatal("expected error for nil value")
		}
	})

	t.Run("Put allows empty byte slice", func(t *testing.T) {
		bridge := newFakeBridge()
		storage := securekv.NewSecureKeyValueStorage(bridge)

		err := storage.Put(ctx, "key", []byte{})
		if err != nil {
			t.Fatalf("Put() error = %v, empty slice should be allowed", err)
		}
	})
}

func TestWithSecret(t *testing.T) {
	ctx := context.Background()

	t.Run("invokes fn with plaintext fetched from bridge", func(t *testing.T) {
		bridge := newFakeBridge()
		bridge.getBytes = []byte("plaintext")
		storage := securekv.NewSecureKeyValueStorage(bridge)

		secret, _ := storage.Get(ctx, "key")
		var got []byte

		err := secret.WithSecret(func(b []byte) error {
			got = append([]byte(nil), b...)
			return nil
		})

		if err != nil {
			t.Fatalf("WithSecret() error = %v", err)
		}
		if string(got) != "plaintext" {
			t.Fatalf("fn received %q, want %q", got, "plaintext")
		}
	})

	t.Run("clears the buffer on success", func(t *testing.T) {
		bridge := newFakeBridge()
		bridge.getBytes = []byte("plaintext")
		storage := securekv.NewSecureKeyValueStorage(bridge)

		secret, _ := storage.Get(ctx, "key")
		var captured []byte

		_ = secret.WithSecret(func(b []byte) error {
			captured = b
			return nil
		})

		assertZeroed(t, captured)
	})

	t.Run("clears the buffer on error", func(t *testing.T) {
		bridge := newFakeBridge()
		bridge.getBytes = []byte("plaintext")
		storage := securekv.NewSecureKeyValueStorage(bridge)

		secret, _ := storage.Get(ctx, "key")
		boom := errors.New("boom")
		var captured []byte

		err := secret.WithSecret(func(b []byte) error {
			captured = b
			return boom
		})

		if !errors.Is(err, boom) {
			t.Fatalf("expected boom, got %v", err)
		}
		assertZeroed(t, captured)
	})

	t.Run("clears the buffer on panic", func(t *testing.T) {
		bridge := newFakeBridge()
		bridge.getBytes = []byte("plaintext")
		storage := securekv.NewSecureKeyValueStorage(bridge)

		secret, _ := storage.Get(ctx, "key")
		var captured []byte

		func() {
			defer func() { _ = recover() }()
			_ = secret.WithSecret(func(b []byte) error {
				captured = b
				panic("boom")
			})
		}()

		assertZeroed(t, captured)
	})

	t.Run("multiple WithSecret on the same Secret fetch fresh each time", func(t *testing.T) {
		bridge := newFakeBridge()
		bridge.getBytes = []byte("plaintext")
		storage := securekv.NewSecureKeyValueStorage(bridge)

		secret, _ := storage.Get(ctx, "key")

		for i := range 3 {
			var got []byte
			err := secret.WithSecret(func(b []byte) error {
				got = append([]byte(nil), b...)
				return nil
			})
			if err != nil {
				t.Fatalf("iteration %d: WithSecret error = %v", i, err)
			}
			if string(got) != "plaintext" {
				t.Fatalf("iteration %d: got %q, want plaintext", i, got)
			}
		}
	})
}

func assertZeroed(t *testing.T, buf []byte) {
	t.Helper()
	if len(buf) == 0 {
		t.Fatal("captured buffer is empty; nothing to verify")
	}
	for i, b := range buf {
		if b != 0 {
			t.Fatalf("byte %d not zeroed: got %x", i, b)
		}
	}
}
