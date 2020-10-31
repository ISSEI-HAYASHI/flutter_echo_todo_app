package handlers

import (
	"net/http"
	"todo_api/models"

	"github.com/labstack/echo"
	"gorm.io/gorm"
)

// GetUsers is a handler for `GET /api/users`.
func GetUsers(c echo.Context) error {
	var user models.User
	user.ID.UnmarshalText([]byte(c.QueryParam("id")))
	user.Name = c.QueryParam("name")

	users, err := models.GetUsers(user)
	if err != nil {
		return internalServerError(err)
	}

	return c.JSON(http.StatusOK, users)
}

// GetUser is a handler for `GET /api/users/:id`
func GetUser(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrBadRequest
	}

	var user models.User
	err = user.Get(id)
	if err == gorm.ErrRecordNotFound {
		return echo.ErrNotFound
	}
	if err != nil {
		return internalServerError(err)
	}

	// Should not return password.
	user.Password = ""
	return c.JSON(http.StatusOK, user)
}

// PostUser is a handler for `POST /api/users`.
func PostUser(c echo.Context) error {
	var user models.User
	err := c.Bind(&user)
	if err != nil {
		return err
	}

	err = user.Create()
	if err != nil {
		return internalServerError(err)
	}

	return c.NoContent(http.StatusCreated)
}

// PutUser is a handler for `PUT /api/users/:id`.
func PutUser(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrBadRequest
	}

	var user models.User
	err = c.Bind(&user)
	if err != nil {
		return err
	}

	user.ID = id
	err = user.Update()
	if err != nil {
		return internalServerError(err)
	}

	return c.NoContent(http.StatusNoContent)
}

// DeleteUser is a handler for `DELETE /api/users/:id`.
func DeleteUser(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrBadRequest
	}

	user := models.User{ID: id}
	err = user.Delete()
	if err != nil {
		return internalServerError(err)
	}

	return c.NoContent(http.StatusNoContent)
}
