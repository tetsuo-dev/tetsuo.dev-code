package main

import (
	"fmt"
        "log"
        "os"
        "path"
        "reflect"
        "io/ioutil"
	"net/http"
        "net/url"
        "github.com/gin-gonic/gin"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
        swaggerFiles "github.com/swaggo/files"
        "github.com/swaggo/gin-swagger"
        _ "github.com/codecowboydotio/go-rest-api/docs"
        "github.com/tidwall/sjson"
        "unit.nginx.org/go"
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
           //c.JSON(http.StatusOK, gin.H{ 
           //  "url": json.Url,
           //  "branch": json.Branch,
           //})
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
               if pull != nil {
               fmt.Printf("pull error: %s\n", pull.Error())
                 c.JSON(http.StatusOK, gin.H{
                       "message": pull.Error(),
                       "repository": json.Url,
                       "branch": json.Branch})
                 return
               } else { //end pull.error
                 fmt.Printf("pull error: %s\n", pull.Error())
                   c.JSON(http.StatusOK, gin.H{
                         "message": pull.Error(),
                         "repository": json.Url,
                         "branch": json.Branch})
                   return
               }  //end pull no error
               if err != nil { fmt.Printf(err.Error()) }
             } // end if repository exists
             c.JSON(http.StatusOK, gin.H{
                   "error": err.Error(),
                   "repository": json.Url,
                   "branch": json.Branch})
             return
           } else {
             //If we hit here then there is no error in the original PlainClone()
             c.JSON(http.StatusOK, gin.H{
                   "repository": json.Url,
                   "status": "success",
                   "branch": json.Branch})
             return
           }// end if error on Plainclone
        } else {
           fmt.Printf("stuff: %s\n", json.Url)
           // IF WE HIT HERE IT MEANS THERE IS AN ERROR IN BINDING
           c.JSON(http.StatusBadRequest, gin.H{
                "error": "VALIDATEERR-1",
                "message": err.Error(),
           })
        } // end if/else bindJSON

}

func newApp(c *gin.Context) {
        // Send new request to local unit that configures an app
        // need language type as a varible.

        content, err := ioutil.ReadFile("./template")
        if err != nil {
            log.Fatal("Error when opening file: ", err)
        }
        println(content)
        ajson, _ := sjson.Set("", "app", "version")
        println(ajson)
        fmt.Println(reflect.TypeOf(ajson).String())
        c.JSON(http.StatusOK, gin.H{})
}


// @title GO Rest API Swagger API
// @version 1.0
// @description Swagger API for Golang Project for git rest api
// @termsOfService http://swagger.io/terms/
// @contact.name API Support
// @contact.email svk@codecowboydotio
// @license.name MIT
// @license.url https://github.com/codecowboydotio/go-rest-api/blob/main/LICENSE
func main() {
	router := gin.New()
        router.GET("/", homeLink)
        router.POST("/pull", gitPull)
        router.GET("/app", newApp)
        router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

        unit.ListenAndServe(":8080", router)
        //router.Run(":8081")
}
