package main

import (
	"fmt"
        "os"
        "path"
        "io/ioutil"
	"net/http"
        "net/url"
        "github.com/gin-gonic/gin"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
        swaggerFiles "github.com/swaggo/files"
        "github.com/swaggo/gin-swagger"
        _ "github.com/codecowboydotio/go-rest-api/docs"
        "unit.nginx.org/go"
        "encoding/json"
        "github.com/tidwall/sjson"
)


func homeLink(c *gin.Context) {
        // send to swagger docs
        c.Redirect(http.StatusFound, "/swagger/index.html")
}

// @BasePath /api/v1
// HealthCheck godoc
// @Summary Pull a github repository down.
// @Description Pull a github repository down.
// @Tags root
// @Accept json
// @Produce json
// @Param   branch body string true "Branch Name"
// @Success 200 {object} map[string]interface{}
// @Router /pull [post]
func gitPull(c *gin.Context) {
        // check the filesystem.
        // if it exists just do a pull
        // otherwise do a clone
        //var json  struct - should be externalised as part of model
        json := struct { 
        // We don't need a destination here as we will be using a standardised destination on the server
            Url string `json:"url" binding:"required"`
            Branch string `json:"branch" binding:"required"`
        }{}

        if err := c.BindJSON(&json); err == nil {
           // IF NO ERROR IN BINDING
           fmt.Printf("No error in JSON binding: URL: %s Branch: %s\n", json.Url, json.Branch) 
           // Perform GIT pull as a first try
           targetUrl, err := url.Parse(json.Url)
           r, err := git.PlainClone("/apps/" + path.Base(targetUrl.Path), false, &git.CloneOptions{
              URL:      json.Url,
              ReferenceName: plumbing.ReferenceName(fmt.Sprintf("refs/heads/%s", json.Branch)),
	      SingleBranch:  true,
              Progress: os.Stdout,
           })
           fmt.Printf("Return from git clone: %s\n", r) 
           if err != nil {
           //At this point, if there is something in the repository it means it has been cloned before
           //We should do a pull to update it rather than a clone.
             if err.Error() == "repository already exists" {
               r, err := git.PlainOpen("/apps/" + path.Base(targetUrl.Path))
               w, err := r.Worktree() 
               pull := w.Pull(&git.PullOptions{
                 RemoteName: "origin",
                 ReferenceName: plumbing.ReferenceName(fmt.Sprintf("refs/heads/%s", json.Branch)),
               })
               fmt.Printf("pull: %s\n", pull)
               fmt.Printf("pull: %T\n", pull)
               if pull == nil { 
                 c.JSON(http.StatusOK, gin.H{
                       "message": "Performed pull on existing repo to get updates from origin",
                       "repository": json.Url,
                       "branch": json.Branch})
                 return
               } //end of pull has no error
               if pull != nil {
                 fmt.Printf("git pull not equal nil")
                 c.JSON(http.StatusOK, gin.H{
                       "message": pull.Error(),
                       "repository": json.Url,
                       "branch": json.Branch})
                 return
               } // end of error on pull request
               if err != nil { fmt.Printf(err.Error()) }
             } // end if repository exists
             // report the error from the repo - likely to be repo exists
             c.JSON(http.StatusOK, gin.H{
                   "message": err.Error(),
                   "repository": json.Url,
                   "branch": json.Branch})
             return
           } else {
             fmt.Printf("no error and clone success")
             c.JSON(http.StatusOK, gin.H{
                   "repository": json.Url,
                   "branch": json.Branch,
                   "message": "success"})
           } //end no error and clone success 
        } else { //end of if statement on binding
           fmt.Printf("Binding: %s\n", json.Url)
           // IF WE HIT HERE IT MEANS THERE IS AN ERROR IN BINDING
           c.JSON(http.StatusBadRequest, gin.H{
                "error": "VALIDATEERR-1",
                "message": err.Error(),
           })
        } // end if/else bindJSON

}

// @BasePath /api/v1
// HealthCheck godoc
// @Summary Generate a new app config to send to unit
// @Description Generate a new app config to send to unit
// @Tags root
// @Accept json
// @Produce json
// @Param   branch body string true "Branch Name"
// @Success 200 {object} map[string]interface{}
// @Router /app [get]
func newApp(c *gin.Context) {
        // Send new request to local unit that configures an app
        // need language type as a varible.


        type GIDmap struct {
          Host 		int `json:"host"`
          Container 	int `json:"container"`
          Size 		int `json:"size"`
        }

        type UIDmap struct {
          Host 		int `json:"host"`
          Container 	int `json:"container"`
          Size 		int `json:"size"`
        }

        type Namespaces struct {
          Cgroup	bool	`json:"cgroup"`	
          Credential	bool	`json:"credential"`
          Mount		bool	`json:"mount"`
          Network	bool	`json:"network"`
          PID		bool	`json:"pid"`
          Uname		bool	`json:"uname"`
        }
        type Processes struct {
          Max		int	`json:"max"`
          Spare		int	`json:"spare"`
          Idle_timeout	int	`json:"idle_timeout"`
        }

        type Isolation struct {
          Namespaces	*Namespaces	`json:"namespaces"`
          Gidmap	*[]GIDmap	`json:"gidmap"`
          Uidmap	*[]UIDmap	`json:"uidmap"`
        }
        //type Arguments struct {
        //  ghfjdkghdfkghfdkjlh
        //}
        type Node struct {
          Type			string		`json:"type"`
          Working_directory	string		`json:"working_directory"`
          Executable		string		`json:"executable"`
          //Arguments		*Arguments	`json:"arguments"`
          Processes     	*Processes      `json:"processes"`
          Isolation     	*Isolation      `json:"isolation"`
        }
        type Applications struct {
          Node		*Node		`json:"node"`
        }
        type unitConfig struct {
          Applications		*Applications		`json:"applications"`
        }

        templatefile, err := os.Open("./unit-configs/unit-template")
        if err != nil {
            //If there is an error reading the file
            c.JSON(http.StatusBadRequest, gin.H{
                "error": "TEMPLATEERR-1",
                "message": err.Error(), 
            })
        } else {
            //If there is no error in reading the file
            content, _ := ioutil.ReadAll(templatefile)
            println(content)
            var config unitConfig
            json.Unmarshal(content, &config)
            c.JSON(http.StatusOK, gin.H{
                "message": config, 
            })
        } // end else err
}


func genNode(c *gin.Context) {
  const json = `{listeners: {"foo": {"pass":"foo"}}}`
  value, _ := sjson.Set(json, "listeners.foo", "*:8081")
  println(json)
  println(value)

  c.JSON(http.StatusOK, gin.H{
    "message": value, 
  })
}

func genPython(c *gin.Context) {
            c.JSON(http.StatusOK, gin.H{
                "message": "python", 
            })
}

// @title Tetsuo GO Rest API Swagger
// @version 1.0
// @description Swagger API for Tetsuo Golang Project for git rest api
// @termsOfService http://swagger.io/terms/
// @contact.name API Support
// @contact.email svk@codecowboydotio
// @license.name MIT
// @license.url https://github.com/codecowboydotio/go-rest-api/blob/main/LICENSE
func main() {
	router := gin.New()
        router.GET("/", homeLink)
        router.POST("/pull", gitPull)
        //router.GET("/app", newApp)
        //router.GET("/gen/node", genNode)
        //router.GET("/gen/python", genPython)
        router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

        unit.ListenAndServe(":8080", router)
        //router.Run(":8081")
}
