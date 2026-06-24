package securekv

import (
	"strings"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/app_provided_data"
)

type (
	NotFoundError         struct{ error }
	DecryptionFailedError struct{ error }
	StorageFailedError    struct{ error }
)

func newNotFoundError(err error) error {
	return &NotFoundError{
		errors.Errorf("secure key-value storage: not found: %w", err),
	}
}

func newDecryptionFailedError(err error) error {
	return &DecryptionFailedError{
		errors.Errorf("secure key-value storage: decryption failed: %w", err),
	}
}

func newStorageFailedError(err error) error {
	return &StorageFailedError{
		errors.Errorf("secure key-value storage: storage failed: %w", err),
	}
}

func classifyError(err error) error {
	if err == nil {
		return nil
	}
	msg := err.Error()
	if strings.Contains(msg, app_provided_data.ErrCodeNotFound) {
		return newNotFoundError(err)
	}
	if strings.Contains(msg, app_provided_data.ErrCodeDecryptionFailed) {
		return newDecryptionFailedError(err)
	}
	return newStorageFailedError(err)
}
