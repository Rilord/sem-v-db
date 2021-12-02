const pool = require('./pool').pool;

const selectQuery = (queryContent) => {
	return new Promise(function(resolve, reject) {
		pool.query(queryContent['query'], (err, results) => {
			if (err) {
				reject(error)
			}
			resolve(results.rows)
		})
	})
}


async function updateQuery(queryContent) {
//	return new Promise(function(resolve, reject) {
//		pool.query(queryContent['query'], (err, results) => {
//			if (err) {
//				reject(error)
//			}
//			resolve('Success')
//		})
//	})
	const res = await pool.query(queryContent['query']);
	if (res.rowCount <= 0) {
		throw 'Failed';
	} else {
		console.log(res);
		return res.rows;
	}
}


const addQuery = (queryContent) => {
	return new Promise(function(resolve, reject) {
		console.debug(queryContent['query']);
		pool.query(queryContent['query'], (err, results) => {
			if (err) {
				reject(error)
			}
			resolve(results.rows)
		})
	})
}

exports.addQuery = addQuery;
exports.selectQuery = selectQuery;
exports.updateQuery = updateQuery;
