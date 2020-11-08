package models

import (
	"log"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// User is a model for users.
type User struct {
	ID       uuid.UUID `json:"id"`
	Name     string    `json:"name" gorm:"not null,unique"`
	Password string    `json:"password,omitempty" gorm:"not null"`
}

// BeforeCreate make default `user.id` and hash password.
func (user *User) BeforeCreate(tx *gorm.DB) error {
	user.ID = uuid.New()
	user.Password = HashPassword(user.Password)
	return nil
}

// HashPassword hashes password by bcrypt
func HashPassword(plain string) string {
	hashed, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal(err)
	}
	return string(hashed)
}

// Get a user by id.
func (user *User) Get(id uuid.UUID) error {
	return db.First(user, id).Error
}

// Create a given user.
func (user *User) Create() error {
	return db.Create(user).Error
}

// Update user with current values.
func (user *User) Update() error {
	return db.Save(user).Error
}

// Delete user from database.
func (user *User) Delete() error {
	return db.Delete(user).Error
}

// GetUserByName selects from user by name.
func GetUserByName(name string) (User, error) {
	var user User
	res := db.Where("name = ?", name).First(&user)
	return user, res.Error
}

// GetUsers returns users filtered by given user's values.
func GetUsers() ([]User, error) {
	var users []User
	res := db.Find(&users)
	println(res)
	return users, res.Error
}
