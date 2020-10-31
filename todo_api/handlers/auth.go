package handlers

import (
	"net/http"
	"todo_api/models"

	"github.com/dgrijalva/jwt-go"
	"github.com/google/uuid"
	"github.com/labstack/echo"
	"golang.org/x/crypto/bcrypt"
)

// SigningKey is the key for JWT.
const SigningKey = "secret"

// Signup is a handler for `POST /signup`.
func Signup(c echo.Context) error {
	var user models.User
	err := c.Bind(&user)
	if err != nil {
		return err
	}

	if user.Name == "" || user.Password == "" {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid name or password")
	}

	u, _ := models.GetUserByName(user.Name)
	if u.Name == user.Name {
		return echo.NewHTTPError(http.StatusConflict, "Name already exists")
	}

	err = user.Create()
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}

	user.Password = ""
	return c.JSON(http.StatusCreated, user)
}

// Login is a handler for `POST /login`
func Login(c echo.Context) error {
	var u models.User
	err := c.Bind(&u)
	if err != nil {
		return err
	}

	user, err := models.GetUserByName(u.Name)
	if err != nil || bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(u.Password)) != nil {
		return echo.NewHTTPError(http.StatusUnauthorized, "Invalid name or password")
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.StandardClaims{
		Id:       uuid.New().String(),
		Issuer:   "lkh42t",
		Audience: user.Name,
	})
	t, err := token.SignedString([]byte(SigningKey))
	if err != nil {
		return err
	}
	// fmt.Println(user.Name)
	return c.JSON(http.StatusOK, map[string]string{"token": t,
		"userID":   user.ID.String(),
		"userName": user.Name})
}
