package app_provided_data

// Native bridges must include these strings in error messages so the Go side
// can classify them into typed errors.
const (
	ErrCodeNotFound         = "NOT_FOUND"
	ErrCodeDecryptionFailed = "DECRYPTION_FAILED"
)
