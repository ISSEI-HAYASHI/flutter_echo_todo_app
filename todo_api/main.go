package main

import (
	"todo_api/handlers"

	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

func main() {
	e := echo.New()
	e.Use(middleware.StaticWithConfig(middleware.StaticConfig{
		Root:   "images",
		Browse: true,
	}))
	e.Use(middleware.Logger())

	e.POST("/signup", handlers.Signup)
	e.POST("/login", handlers.Login)
	e.POST("/upload", handlers.SaveImage)
	// e.GET("/download/:filename", handlers.SendImage)

	api := e.Group("/api")
	// To use API, authorization is required.
	api.Use(middleware.JWT([]byte(handlers.SigningKey)))

	// API for users
	api.GET("/users/", handlers.GetUsers)
	api.GET("/users/:id", handlers.GetUser)
	// api.POST("/users", handler.PostUser)
	api.PUT("/users", handlers.PutUser)
	api.DELETE("/users", handlers.DeleteUser)

	// API for todos
	api.GET("/todos/:id/:done", handlers.GetTodos)
	api.GET("/todos/:id", handlers.GetTodo)
	api.POST("/todos", handlers.PostTodo)
	api.PUT("/todos/:id", handlers.PutTodo)
	api.DELETE("/todos/:id", handlers.DeleteTodo)

	//API for projects
	api.GET("/projects/", handlers.GetProjects)
	api.POST("/projects/", handlers.PostProject)
	api.DELETE("/projects/:id", handlers.DeleteProject)

	e.Logger.Fatal(e.Start(":8000"))
}
