/*
Legacy-wiki Router

This is a cloudflare worker that redirects old wiki url to the new wiki.

The old urls need to be remapped to point to the worker. 
In the current configuration the worker is hosted at https://wiki.jmonkeyengine.org/legacy/
the following commands were used to remap the urls on discourse
rake posts:remap["http://hub.jmonkeyengine.org/wiki/","https://wiki.jmonkeyengine.org/legacy/"]
rake posts:remap["https://hub.jmonkeyengine.org/wiki/","https://wiki.jmonkeyengine.org/legacy/"]
rake posts:remap["https://github.com/jMonkeyEngine/wiki.jmonkeyengine.org/blob/master/","https://wiki.jmonkeyengine.org/legacy/"]

The following urls were taken into consideration:
OLD doku wiki: http(s)://hub.jmonkeyengine.org/wiki/doku.php/sdk:troubleshooting
github direct link: https://github.com/jMonkeyEngine/wiki.jmonkeyengine.org/blob/master/sdk/troubleshooting.md 
wiki link without version: https://wiki.jmonkeyengine.org/sdk/troubleshooting.html
*/

addEventListener("fetch", (event) => {
    event.respondWith(
      handleRequest(event.request).catch(
        (err) => new Response(err.stack, { status: 500 })
      )
    );
  });
  
  const oldWikiBasePath="docs/3.2";
  const newWikiUrl="https://wiki.jmonkeyengine.org/"
  async function handleRequest(request) {
    let { pathname } = new URL(request.url);
    if(!pathname.startsWith("/legacy/"))return;
    pathname=pathname.substring("/legacy".length);
  
    if(pathname.startsWith("/doku.php/")){ // route 1
        //let docpath=pathname.split("/doku.php/")[1];
        //docpath=docpath.split(":").join("/");
        //docpath=oldWikiBasePath+"/"+docpath+".html";
        //return Response.redirect(newWikiUrl+docpath, 301);
        let archivedUrl="https://web.archive.org/web/http://hub.jmonkeyengine.org/wiki/"+pathname;
        return Response.redirect(archivedUrl, 301);
    }else{ // route 2
      let docpath=pathname;
      if(!docpath.startsWith(oldWikiBasePath)){
        docpath=oldWikiBasePath+docpath;
      }
      docpath=docpath.replaceAll(".md",".html");
      return Response.redirect(newWikiUrl+docpath, 301);
    }
    
    return null;
  }
