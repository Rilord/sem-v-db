const express = require('express')
const controllers = require('./controllers')
const cors = require('cors');
const app = express()
const port = process.env.PORT | 3011;

app.use(express.json())
app.use(express.urlencoded({ extended: true }));

app.use(cors());


app.get('/', (req, res) => {
	res.status(200).send('Hello!');
})


app.post('/upload', (req, res) => {
	controllers.addQuery(req.body)
		.then(response => {
			res.status(200).send(response);
		})
		.catch(error => {
			res.status(500).send(error);
		})
})

app.post('/select', (req, res) => {
	console.debug(req.body);
	controllers.selectQuery(req.body)
		.then(response => {
			res.status(200).send(response);
		})
		.catch(error => {
			res.status(500).send(error);
		})
})


app.post('/update', (req, res) => {
	console.debug(req.body);
	controllers.updateQuery(req.body)
		.then(response => {
			res.status(200).send(response);
		})
		.catch(error => {
			res.status(500).send(error);
		})
})

app.use('/login', (req, res) => {
	
});



app.listen(port, () => {
	console.log(`App running on port ${port}`)
})	
