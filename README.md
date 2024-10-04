# onboard-assignment

browserstack technical onboarding assignments
Key Server
Routes 
# GET "/key/generate" => to generate a key
# GET "/key/info" => to see key data lie available keys
# GET "/key/block" => to block one of the available key
# POST "/key/unblock" => to unblock
# Delete "/key/purge"
# PUT "/key/refresh" => to keep alive key

There are two files for controllers
KeyManager : It contains O(n) implementation
KeyManagerV2 : It contains O(log n) implementation 
ruby main.rb
