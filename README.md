# The

This is an example app that shows launches of Space X's Falcon 9 rockets.

# Aims
I like to use example projects to test out ideas. For this project I started out with the aim of using more Combine, and specifically trying to work out how Combine could be used to read a paging api. Ideally this would be generic, so that it could be reusable.

# What I'd do given more time
The NetworkManager class's `fetchQuery()` function ended up being only half generic. The LaunchQuery is specific to `/launches` api. I could make it more flexible, but it already feels over-engineered for this simple project. While the networking aspect is over-engineered for the task, I feel OK with that as I was keen to show an architecture that would scale beyond this simple starting point.

I was hoping to have infinite scrolling, where the app would automatically load the next page. From iOS 14.0 forward `onAppear` acts differently, which wuold make this functionality comparitvely simple for a basic implementation. Unfortunately using the iOS 13 version of the api `onAppear` acts differently. There's a way to get it to work using GeometryReader, but in the end I decided to go with a "Load More" button.

The image loading currently doesn't try to retry if a request fails.

# References
[Space X API documentation](https://github.com/r-spacex/SpaceX-API/)

# License
This code is available under the MIT license: https://opensource.org/licenses/MIT
