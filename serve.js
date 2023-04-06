const path = require('path')
const express = require('express')
const app = express()
const port = 3333

app.get('/', (req, res) => {
  res.redirect('/static')
})

app.use('/static', express.static(path.join(__dirname, 'public')))

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})

