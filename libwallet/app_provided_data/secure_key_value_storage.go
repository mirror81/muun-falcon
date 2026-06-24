package app_provided_data

// SecureKeyValueStorage provides hardware-encrypted key-value storage backed by native
// secure storage (Android KeyStore / iOS Keychain).
type SecureKeyValueStorage interface {
	// Put encrypts and stores the value under the given key (upsert).
	Put(key string, value []byte) error

	// Get returns the plaintext stored under the given key.
	// Only WithSecret invokes this; wiping happens there.
	Get(key string) ([]byte, error)

	// Delete removes the value under the given key. No-op if missing.
	Delete(key string) error

	// Wipe deletes everything in the underlying native storage.
	Wipe() error
}
