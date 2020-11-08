package handlers

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
	"todo_api/models"

	"github.com/google/uuid"

	"github.com/labstack/echo"
	"gorm.io/gorm"
)

// GetTodos is a handler for `GET /api/todos`.
func GetTodos(c echo.Context) error {
	// var todo models.Todo
	quids := c.Param("users")
	qprjids := c.Param("projects")
	qdone := c.Param("done")
	uids := GetIDSlice(quids)
	prjids := GetIDSlice(qprjids)
	var done bool
	if qdone == "1" || qdone == "true" {
		done = true
	} else {
		done = false
	}
	todos, err := models.GetTodos(uids, prjids, done)
	if err != nil {
		return internalServerError(err)
	}

	return c.JSON(http.StatusOK, todos)
}

//GetIDSlice returns slice of uuids for gettodos
func GetIDSlice(s string) []uuid.UUID {
	s = strings.Trim(s, "[")
	s = strings.Trim(s, "]")
	sSlice := strings.Split(s, ",")
	var idSlice []uuid.UUID
	for _, str := range sSlice {
		u, err := uuid.Parse(str)
		if err == nil {
			idSlice = append(idSlice, u)
		}
	}
	return idSlice
}

// GetTodo is a handler for `GET /api/todos/:id`.
func GetTodo(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrNotFound
	}

	var todo models.Todo
	err = todo.Get(id)
	if err == gorm.ErrRecordNotFound {
		return echo.NewHTTPError(http.StatusNotFound, err.Error())
	}
	if err != nil {
		return internalServerError(err)
	}

	return c.JSON(http.StatusOK, todo)
}

// PostTodo is a handler for `POST /api/todos`.
func PostTodo(c echo.Context) error {
	todo := new(models.Todo)
	err := c.Bind(&todo)
	if err != nil {
		return err
	}
	if id := todo.ProjectID; id != uuid.Nil {
		var prj models.Project
		err := prj.Get(id)
		if err == gorm.ErrRecordNotFound {
			return echo.NewHTTPError(http.StatusNotFound, err.Error())
		}
		if err != nil {
			return internalServerError(err)
		}
		todo.Project = prj
	}

	err = todo.Create()
	if err != nil {
		return internalServerError(err)
	}

	return c.JSON(http.StatusCreated, nil)
}

//SaveImage is a handler for `POST /api/upload`.
func SaveImage(c echo.Context) error {
	file, err := c.FormFile("file")
	if err != nil {
		return err
	}
	src, err := file.Open()
	if err != nil {
		return err
	}
	defer src.Close()

	// Destination
	p := "images/" + file.Filename
	dst, err := os.Create(p)
	if err != nil {
		return err
	}
	defer dst.Close()

	// Copy
	if _, err = io.Copy(dst, src); err != nil {
		return err
	}
	return c.String(http.StatusOK, file.Filename)
}

//DeleteImage is a handler for `DELETE /api/images/:filename`
func DeleteImage(c echo.Context) error {
	fileName := c.Param("filename")
	err := os.Remove("images/" + fileName)
	if err != nil {
		return c.NoContent(http.StatusNotFound)
	}
	return c.NoContent(http.StatusNoContent)
}

// PutTodo is a handler for `PUT /api/todos/:id`.
func PutTodo(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrNotFound
	}

	var todo models.Todo
	err = c.Bind(&todo)
	if err != nil {
		return err
	}

	todo.ID = id
	err = todo.Update()
	if err != nil {
		return internalServerError(err)
	}
	fmt.Print(time.Now())
	return c.NoContent(http.StatusNoContent)
}

// DeleteTodo is a handler for `DELETE /api/todos/:id`
func DeleteTodo(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrNotFound
	}

	todo := models.Todo{ID: id}
	err = todo.Delete()
	if err != nil {
		return internalServerError(err)
	}

	return c.NoContent(http.StatusNoContent)
}
