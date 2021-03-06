puts "REMOVING OLD DUMMY APP AT spec/dummy/ ......."
`rm -rf spec/dummy/`
puts "BUILDING THE DUMMY APP AT spec/dummy/ ......."
`rails new spec/dummy/ --skip-webpack-install `
`cd spec/dummy/ && rails webpacker:install`
`cd ../..`
puts "LOADING THE DUMMY APP BEFORE RUNNING INTERNAL SPECS ......."