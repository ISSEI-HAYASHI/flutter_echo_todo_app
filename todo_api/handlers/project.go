package handlers

import (
	"net/http"
	"todo_api/models"
	"gorm.io/gorm"
	"github.com/google/uuid"

	"github.com/labstack/echo"
)

//GetProjects is a handler for `POST /api/projects `
func GetProjects(c echo.Context) error {
	prjs, err := models.GetProjects()
	if err != nil {
		return internalServerError(err)
	}
	return c.JSON(http.StatusOK, prjs)
}

// GetProject is a handler for `GET /api/projects/:id`.
func GetProject(c echo.Context) error {
	id, err := getUUIDFromParam(c)
	if err != nil {
		return echo.ErrNotFound
	}

	var prj models.Project
	err = prj.Get(id)
	if err == gorm.ErrRecordNotFound {
		return echo.NewHTTPError(http.StatusNotFound, err.Error())
	}
	if err != nil {
		return internalServerError(err)
	}

	return c.JSON(http.StatusOK, prj)
}

// PostProject is a handler for `POST /api/projects`.
func PostProject(c echo.Context) error {
	println("PostProject.")
	prj := new(models.Project)
	err := c.Bind(&prj)
	if err != nil {
		return err
	}
	err = prj.Create()
	if err != nil {
		return internalServerError(err)
	}
	return c.JSON(http.StatusCreated, nil)
}

// DeleteProject is a handler for `DELETE /api/projects/:id`
func DeleteProject(c echo.Context) error {
	id := uuid.MustParse(c.Param("id"))
	prj := models.Project{ID: id}
	err := prj.Delete()
	if err != nil {
		return internalServerError(err)
	}
	return c.NoContent(http.StatusNoContent)
}
