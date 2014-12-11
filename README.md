wkpdf
=====

wkpdf is no longer maintained

My objective for wkpdf was providing the user with a simple installation experience on a stock OS X installation. I was excited when Apple started shipping RubyCocoa in OS X 10.5 because this meant that wkpdf could be installed easily using the rubygems package manager, without requiring the user to modify the system ruby installation with a RubyCocoa instalation. The official adoption of RubyCocoa by Apple, motivated me to port wkpdf from its initial incarnation in Objective-C to Ruby.

However, in OS X 10.9. Apple stopped shipping RubyCocoa with its default Ruby, which was upgraded at the same time from 1.8 to 2.x. While Apple still shipped RubyCocao for Ruby version 1.8, which was installed in parallel on OS X 10.9 for compatibility reasons, the writing was on the wall that RubyCocoa will be going away in the not too distant future. Thus it didn't come as a surprise when OS X 10.10 shipped without Ruby 1.8 and without RubyCocoa.

While wkpdf reportedly works in OS X 10.10 after RubyCocoa is installed with the binary installer, this is not the way I would like wkpdf to be installed. I like my system Ruby installation to be untouched, because messing with system Ruby will cause problems in the long run. Installing an additional Ruby in a different location may solve the problem for experienced users. But over the years, I received too many support requests from novice users with custom ruby installations, that messed up their installation causing lots of frustration and difficult to diagnose problems. This was my reason for only support a the canonical stock system ruby installation. Because this is no longer possible, I decided, as of December 2014,  to no longer maintain the RubyCocoa version of wkpdf and to pull the corresponding gem from RubyGems.

So what's next? wkpdf was initially ported from a less advanced Objective-C implementation and it would be fairly easy to port the latest wkpdf version from RubyCocoa to Objective-C again, or to Swift. As my own use of wkpdf was very limited over the last couple of years, this is however not very high on my priority list.

**How you can help:** If you are interested to contribute to porting wkpdf from RubyCocoa to Objective-C or Swift, please let me know. If you are not a developer but would like to see a modernized version of wkpdf that runs on a current OS X system, you may consider offering a development bounty. Please get in touch with me, if this is an option for you.






Command line tool for rendering HTML to PDF using WebKit and RubyCocoa on Mac OS X

Although there are plenty of browsers available for Mac OS X, I could not find 
a command-line tool that allows for downloading a website and storing the 
rendered website as PDF. This was my motivation for creating wkpdf. The 
application uses Apple WebKit for rendering the HTML pages, thus the result 
should look similar to what you get when printing the webpage with Safari.

You find the latest information on how to install and use wkpdf on:

  [http://plessl.github.com/wkpdf](http://plessl.github.com/wkpdf)

For questions regarding wkpdf contact: wkpdf@plesslweb.ch

License
=======

Copyright (c) 2007-14 Christian Plessl

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
