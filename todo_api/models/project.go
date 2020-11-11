package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

//Project is models for project
type Project struct {
	ID   uuid.UUID `json:"id" gorm:"primary_key"`
	Name string    `json:"name"`
}

//BeforeCreate sets an id to projects before creation.
func (prj *Project) BeforeCreate(tx *gorm.DB) (err error) {
	prj.ID = uuid.New()
	return nil
}

// Get todo by id.
func (prj *Project) Get(id uuid.UUID) error {
	res := db.First(prj, id)
	return res.Error
}

// Create project with current values.
func (prj *Project) Create() error {
	return db.Create(prj).Error
}

// Delete project from database.
func (prj *Project) Delete() error {
	return db.Delete(prj).Error
}

// GetProjects returns projects filtered by given projects's values.
func GetProjects() ([]Project, error) {
	var prjs []Project
	prjList := db.Find(&prjs)
	err := prjList.Error
	return prjs, err
}
