package handlers

import (
	"net/http"

	"github.com/google/uuid"
	"github.com/labstack/echo"
)

func getUUIDFromParam(c echo.Context) (uuid.UUID, error) {
	var id uuid.UUID
	err := id.UnmarshalText([]byte(c.Param("id")))
	return id, err
}

func internalServerError(err error) error {
	return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
}
