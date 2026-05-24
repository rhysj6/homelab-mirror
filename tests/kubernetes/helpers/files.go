package helpers

import (
	"path/filepath"
	"runtime"
	"testing"
)

func FixturePath(t *testing.T, parts ...string) string {
	t.Helper()

	_, file, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("failed to determine helper file path")
	}

	base := filepath.Dir(filepath.Dir(file))
	all := append([]string{base, "fixtures"}, parts...)
	return filepath.Join(all...)
}
