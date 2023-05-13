package models

type json struct {
  Url 		string `json:"url" binding:"required"`
  Branch 	string `json:"branch" binding:"required"`
}


