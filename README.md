# project-tetsuo

Release 0.1

## What is this?
Welcome to tetsuo.

Tetsuo is the brain child of some people who recognise that the future is code not containers. 

To this end, we have written a facade API on top of NGINX unit to pull down arbitrary code from github onto a unit server. 

This is the first step in making a serverless platform that will eventually do the following things:

- Pull code from a git repo
- Automatically update NGINX unit configuration
- Apply the same codebase and configuration update to other unit servers as part of a cluster (probably using libp2p)


## Where are we at?

With this release 0.1 we have a functioning git API.
We are working on another API to push configuration into UNIT.

I also have a terraform build in AWS of a unit server that deploys the API. 
This will be added shortly.


admins: 
- [@codecowboydotio](https://github.com/codecowboydotio) 
- [@shsingh](https://github.com/shsingh)



slack: https://join.slack.com/t/project-tetsuo/shared_invite/zt-11udr5vev-I7o0yEMXttlyK6B__MUXeg

discord: https://discord.gg/dkHbP7PW

Also check out this: https://codecowboy.io/development/libp2p/ on the beginnings of a distributed control plane.
