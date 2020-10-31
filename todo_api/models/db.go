package models

import (
	"bytes"
	"database/sql"
	"log"

	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
)

var db *gorm.DB

func init() {
	var err error
	db, err = gorm.Open(sqlite.Open("db.sqlite3"), &gorm.Config{
		PrepareStmt: true,
	})
	if err != nil {
		log.Fatal(err)
	}
	db.AutoMigrate(&User{}, &Todo{})
}

// NullTime is wrapper for sql.NullTime to implement `MarshalJSON` and `UnmarshalJSON`.
type NullTime struct {
	sql.NullTime
}

// MarshalJSON is an implementation to handle `null` correctly.
func (t NullTime) MarshalJSON() ([]byte, error) {
	if t.Valid {
		return t.Time.MarshalJSON()
	}
	return []byte("null"), nil
}

// UnmarshalJSON is an implementation to handle `null` correctly.
func (t *NullTime) UnmarshalJSON(data []byte) error {
	if bytes.Compare(data, []byte("null")) == 0 {
		t.Valid = false
		return nil
	}

	err := t.Time.UnmarshalJSON(data)
	if err != nil {
		return err
	}

	t.Valid = true
	return nil
}
