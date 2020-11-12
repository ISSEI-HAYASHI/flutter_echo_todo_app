package models

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Todo is a model for todo.
type Todo struct {
	ID       uuid.UUID `json:"id"`
	Title    string    `json:"title"`
	Memo     string    `json:"memo"`
	ImageURL string    `json:"imageurl"`
	Genre    string    `json:"genre"`
	Done     bool      `json:"done" gorm:"default:false"`
	Start    string    `json:"start"`
	End      string    `json:"end"`
	PersonID uuid.UUID `json:"person"`
	// Person   User
	ProjectID uuid.UUID `json:"projectid"`
	Project   Project   `json:"project" gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
    // 追加
    Notification bool `json:"notificationToggle"`
}

// BeforeCreate make default `todo id`
func (todo *Todo) BeforeCreate(tx *gorm.DB) error {
	todo.ID = uuid.New()
	return nil
}

// Get todo by id.
func (todo *Todo) Get(id uuid.UUID) error {
	res := db.First(todo, id)
	return res.Error
}

// Create todo with current values.
func (todo *Todo) Create() error {
	return db.Create(todo).Error
}

// Update current todo with current values.
func (todo *Todo) Update() error {
	err := db.Save(todo).Error
	return err
}

// Delete todo from database.
func (todo *Todo) Delete() error {
	return db.Delete(todo).Error
}

// GetTodos returns todos filtered by given todo's values.
// func GetTodos(todo Todo) ([]Todo, error) {
// 	var todos []Todo
// 	todoList := db.Order("start").Debug().Where(map[string]interface{}{"person_id": todo.PersonID.String(), "done": todo.Done}).Find(&todos)
// 	err := todoList.Error
// 	return todos, err
// }

// GetTodos returns todos filtered by given todo's values.
func GetTodos(uids []uuid.UUID, prjids []uuid.UUID, done bool) ([]Todo, error) {
	var todos []Todo
	var err error
	if len(uids) == 0 && len(prjids) == 0 {
		todoList := db.Order("start").Debug().Where("done = ?", done).Find(&todos)
		err = todoList.Error
	} else if len(uids) == 0 && len(prjids) != 0 {
		todoList := db.Order("start").Debug().Where("project_id IN ?", prjids).Where("done = ?", done).Find(&todos)
		err = todoList.Error
	} else if len(uids) != 0 && len(prjids) == 0 {
		todoList := db.Order("start").Debug().Where("person_id IN ?", uids).Where("done = ?", done).Find(&todos)
		err = todoList.Error
	} else {
		todoList := db.Order("start").Debug().Where("person_id IN ?", uids).Where("project_id IN ?", prjids).Where("done = ?", done).Find(&todos)
		err = todoList.Error
	}
	return todos, err
}
