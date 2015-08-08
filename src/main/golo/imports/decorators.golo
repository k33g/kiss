module kiss.decorators

#import kiss.request
#import kiss.response
import kiss.httpExchange

# wip
# use only with augmentations

function GET = |route| {
  return |func| {
    return |functionArgs...| {
      let app = functionArgs: get(1)
      app: $get(route, |res, req| {
        func: invokeWithArguments(functionArgs)
      })
    }
  }
}

function DELETE = |route| {
  return |func| {
    return |functionArgs...| {
      let app = functionArgs: get(1)
      app: $delete(route, |res, req| {
        func: invokeWithArguments(functionArgs)
      })
    }
  }
}

function POST = |route| {
  return |func| {
    return |functionArgs...| {
      let app = functionArgs: get(1)
      app: $post(route, |res, req| {
        func: invokeWithArguments(functionArgs)
      })
    }
  }
}

function PUT = |route| {
  return |func| {
    return |functionArgs...| {
      let app = functionArgs: get(1)
      app: $put(route, |res, req| {
        func: invokeWithArguments(functionArgs)
      })
    }
  }
}

function STATIC = |path, page| {
  return |func| {
    return |functionArgs...| {
      let app = functionArgs: get(0)
      app: static(path, page)
      func: invokeWithArguments(functionArgs)
    }
  }
}
