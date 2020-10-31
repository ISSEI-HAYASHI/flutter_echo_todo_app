package handlers

import (
	"net/http"
	"strconv"
	"todo_api/models"

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

// PostProject is a handler for `POST /api/projects`.
func PostProject(c echo.Context) error {
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
	id, _ := strconv.Atoi(c.Param("id"))
	prj := models.Project{ID: id}
	err := prj.Delete()
	if err != nil {
		return internalServerError(err)
	}
	return c.NoContent(http.StatusNoContent)
}
