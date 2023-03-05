# project-tetsuo: deploy code not containers

## What is this?

Welcome to Tetsuo.

Tetsuo is the brain child of some people who recognise that the future is code not containers.

To this end, we have written a facade API on top of NGINX unit to pull down arbitrary code from github onto a unit server.

This is the first step in making a serverless platform that will eventually do the following things:

- Pull code from a git repo
- Automatically update NGINX unit configuration
- Apply the same codebase and configuration update to other unit servers as part of a cluster (probably using [libp2p](https://codecowboy.io/development/libp2p/))

## Why Bother?

This is a good question. One of the drawbacks that I see with the curreent approach to serverless is that I need to refactor my code to enable it to work with most serverless platforms. This usually involves refactoring or wrapping my code in some sort of eventing model or making other changes to suit the proprietary serverless model.

When we first came across NGINX UNIT, we saw that the changes to code needed we minimal to none. Nothing to learn.

This made us think about what other components we would need to make this a reality.

....and Tetsuo was born.
