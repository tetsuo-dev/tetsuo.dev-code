# project-tetsuo: deploy code not containers

Release 0.1

## What is this?
Welcome to tetsuo.

Tetsuo is the brain child of some people who recognise that the future is code not containers. 

To this end, we have written a facade API on top of NGINX unit to pull down arbitrary code from github onto a unit server. 

This is the first step in making a serverless platform that will eventually do the following things:

- Pull code from a git repo
- Automatically update NGINX unit configuration
- Apply the same codebase and configuration update to other unit servers as part of a cluster (probably using libp2p)


## Why Bother?

This is a good question. One of the drawbacks that I see with the curreent approach to serverless is that I need to refactor my code to enable it to work with most serverless platforms. This usually involves refactoring or wrapping my code in some sort of eventing model or making other changes to suit the proprietary serverless model.

When we first came across NGINX UNIT, we saw that the changes to code needed we minimal to none. Nothing to learn.

This made us think about what other components we would need to make this a reality.

....and Tetsuo was born.

## Where are we at?

With this release 0.1 we have a functioning git API.
We are working on another API to push configuration into UNIT.

I also have a terraform build in AWS of a unit server that deploys the API. 
This will be added shortly.

## DEVELOPERS NEEDED!!!!!!!!

admins: 
- [@codecowboydotio](https://github.com/codecowboydotio) 
- [@shsingh](https://github.com/shsingh)



slack: https://join.slack.com/t/project-tetsuo/shared_invite/zt-11udr5vev-I7o0yEMXttlyK6B__MUXeg

discord: https://discord.gg/dkHbP7PW

Also check out this: https://codecowboy.io/development/libp2p/ on the beginnings of a distributed control plane.

