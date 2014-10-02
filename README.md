1. Check out project
2. Run git submodule update --init --recursive from the root directory
3. Run ant in Clicker server and ID server to build them
4. Run npm install on rhombus-grunt-socket-server
5. Launch servers by running start_servers.sh
6. Launch web app by typing "grunt dev" in the web app directory


It looks like my configuration of submodules isn't great. I often get "detached HEAD" when trying to initialize the submodules. This seems to get fixed by going to each submodule, doing a "git checkout master" then "git submodule update --init --recursive" (note that you may have to do this in the framework subdirectories of the rhombus-web projects).
