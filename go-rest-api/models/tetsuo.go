package models

type Tetsuo-git struct {
  Url 		string `json:"url" binding:"required"`
  Branch 	string `json:"branch" binding:"required"`
}


