package models

//Project is models for project
type Project struct {
	ID   int    `json:"id" gorm:"primary_key"`
	Name string `json:"name"`
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
