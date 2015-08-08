module kiss.memdb

import gololang.concurrent.workers.WorkerEnvironment

struct memory = {
  name, data, worker, delay, log
}

augment memory {
  function ignition = |this| {
    this: data(map[])
    let env = WorkerEnvironment.builder(): withCachedThreadPool()
    if this: name() is null { this: name("golodb.json") }
    if this: log() is null { this: log(false) }

    let fileName = currentDir() + "/" + this: name()
    if fileExists(fileName) {
      let text = fileToText(fileName, "UTF-8")
      this: data(JSON.parse(text))
    }

    this: worker(env: spawn(|message| {
      if this: delay() is null { this: delay(1000_L) }

      while message: equals("go") {
        Thread.sleep(this: delay())
        textToFile(JSON.stringify(this: data()), fileName)
        if this: log() { println(this: data())}
      }

      if message:equals("kill") {env: shutdown()}
    }))

    this: worker(): send("go")
    return this
  }
  function stop = |this| {
    this: worker(): send("kill")
  }
  #function collection

}

# for test
function main = |args| {
  let db = memory(): name("bobdb.json"): ignition()

  println(db: data())

  #db: data(): put("001", map[["firstName","Bob"], ["lastName","Morane"]])
  #db: data(): put("002", map[["firstName","John"], ["lastName","Doe"]])
  #db: data(): put("003", map[["firstName","Jane"], ["lastName","Doe"]])
  #db: data(): put("004", map[["firstName","Sam"], ["lastName","Le Pirate"]])

  db: data(): delete("002")

  Thread.sleep(3000_L)

  db: stop()

}