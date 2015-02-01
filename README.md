# simple-twitter-client
A simple twitter client that allows you to search and save tweets

Preview
---
You can search tweets and save them by swiping left

<img width="320 px" src="previews/search.png"/>

view the tweets you saved, delete by swiping left

<img width="320 px" src="previews/saved.png"/>

and view a collection of images from the tweets you saved

<img width="320 px" src="previews/gallery.png"/>

Video
---
Links to a few demo videos
- [Video 1](https://www.dropbox.com/s/3t42j9gvssp3ntq/video.mov?dl=0)
- [Video 2](https://www.dropbox.com/s/8f5istg081fyxiq/videoDelete.mov?dl=0)

Features
---
- Search and save tweets using Twitter search API
- Display associated image if it has one
- Search triggered after timeout
- Support paging for search results

Bugs
---
Search interface -> url -> webview
	should reset the cell before re-rendering

improvement
---
Right now the cell can be configured using both Core Data Object and JSON
	(not very good abstration, code reuse)
Reactive style?
Saving a tweet should trigger some feedback

License
---
simple-twitter-client is available under MIT license. See the LICENSE file for more info.
