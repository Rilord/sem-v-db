import './App.css';
import React, { Component, useState, useEffect} from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';

class Table extends Component {
	constructor(props) {
		super(props)
		this.state = {
			columns: [],
			columnsToHide: ["_id"],
			results: this.props.results,
			token: 0
		}
	}
	componentDidMount() {
		this.mapColumns();
	}
	


	mapColumns = () => {
		let columns = [];
		this.state.results.forEach((result) => {
			Object.keys(result).forEach((col) => {
				if (!columns.includes(col)) {
					columns.push(col);
				}
			});
			this.setState({columns});
		});
	}

	appendRow = (result) => {
		let row = [];
		this.state.columns.forEach((col) => {
			if (!this.state.columnsToHide.includes(col)) {
				row.push(
					Object.keys(result).map((item) => {
						if (result[item] && item === col) {
							return result[item];
						} else if (item === col) {
							return "-";
						}
					})
				);
			}
		});

		return row.map((item, index) => {
			return (
				<td key = {`${item}--${index}`} 
				className="px-6 py-4 whitespace-nowrap">

				{item}
			</td>
			)
		});
	};

	mapTableColumns = () => {
		return this.state.columns.map((col) => {
			if (!this.state.columnsToHide.includes(col)) {
				const overridedColumnName = this.overrideColumnName(col);
				return (
					<th
					key={col}
					scope="col"
					className="px-6 py-3 bg-gray-50
					text-left text-xs font-medium
					text-gray-500 uppercase tracking-wider"
				>
						{overridedColumnName}
				</th>
				);
			}
		});
	};


	filterDeepUndefinedValues = (arr) => {
		return arr
			.map((val) =>
				val.map((deepVal) => deepVal).filter((deeperVal) => deeperVal)
			)
			.map((val) => {
				if (val.length < 1) {
					val = ["-"];
					return val;
				}
				return val;
			});
	};

	createTable = (results) => {
		return (
			<table class="min-w-full divide-y divide-gray-200">
				<thead>
					<tr>{this.mapTableColumns()}</tr>
				</thead>
				<tbody>
					{results.map((result, index) => {
						return <tr key={result._id}>{this.appendRow(result)}</tr>;
					})}
					</tbody>
				</table>
		);
	};

	overrideColumnName = (colName) => {
		switch (colName) {
			case "phoneNumber":
				return "Phone number";
			case "lastname":
				return "Custom Last Name";
			default:
				return colName;
		}
	};

	render() {
		return (
			<div class="flex flex-col">
				<div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
					<div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
						<div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
							{this.state.results.length ? (
								<div className="card">
									{this.createTable(this.props.results)}
								</div>
							) : null}
							</div>
						</div>
					</div>
				</div>
		);
	}
}

class App extends Component {
	constructor(props) {
		super(props);
		this.state = {
			selQuery: "SELECT * FROM public.coffee_shop LIMIT 100;",
			updQuery: "UPDATE public.coffee_shop SET rating='Great' WHERE city='Moscow';",
			selectResult: [],
			updateResult: [],
			selectExecuted: false,
			updateExecuted: false,

		}
	}

	selectQuery = (event) => {
		event.preventDefault();
		const copy = this;
		fetch('http://localhost:3011/select', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ "query": this.state.selQuery }),
		})
			.then(response => {
				return response.text();
			})
			.then(data => {
				copy.setState({ selectExecuted: false });
				copy.setState({ selectResult: JSON.parse(data) });
				copy.setState({ selectExecuted: true });
			});
	}

	selectQueryChangeHandle = (event) => {
		this.setState({ selQuery: event.target.value });
	}

	updateQueryChangeHandle = (event) => {
		this.setState({ updQuery: event.target.value });
	}

	updateQuery = (event) => {
		event.preventDefault();
		const copy = this;
		fetch('http://localhost:3011/update', {
			method: 'POST',
			headers: {
				'Content-Type': 'application/json',
			},
			body: JSON.stringify({ "query": this.state.updQuery }),
		})
			.then(response => {
				return response.text();
			})
			.then(data => {
				copy.setState({ updateExecuted: false });
				copy.setState({ updateResult: JSON.parse(data) });
				copy.setState({ updateExecuted: true });
			});
	}


	render() {

		let selectTable, updateTable;
		if (this.state.selectExecuted == true) {
			selectTable = <Table results={this.state.selectResult}/>;
		} else {
			selectTable = <h3>Run select query</h3>;
		}

		if (this.state.updateExecuted == true) {
			updateTable = <h3>Query {this.state.updQuery} has been executed</h3>;
		} else {
			updateTable = <h3>Run update query</h3>;
		}

		return (
			<div className="App">
				<div class="container">
					<div class="row selectForm">
						<div class="col">
							<form onSubmit={this.selectQuery}>
								<div class="form-group col-md-6">
									<label for="queryInput">Enter your select query</label>
									<div class="">
										<textarea type="text" rows="4" class="form-control" id="queryInput" value={this.state.selQuery} onChange={this.selectQueryChangeHandle}></textarea>
									</div>
								</div>
								<button type="submit" class="btn btn-primary">Submit</button>
							</form>
						</div>
						<div class="col">
							<form onSubmit={this.updateQuery}>
								<div class="form-group col-md-6">
									<label for="queryInput">Enter your update query</label>
									<div class="">
										<textarea type="text" rows="4" class="form-control" id="queryInput" value={this.state.updQuery} onChange={this.updateQueryChangeHandle}></textarea>
									</div>
								</div>
								<button type="submit" class="btn btn-primary">Submit</button>
							</form>
						</div>
					</div>
					<div class="row">
						<div class="table-wrapper-scroll-y table-scrollbar">
							<table class="table table-bordered table-striped mb-0">
								{selectTable}
							</table>
						</div>
					</div>
					<div class="row">
						<div class="table-wrapper-scroll-y table-scrollbar">
							<table class="table table-bordered table-striped mb-0">
								{updateTable}
							</table>
						</div>
					</div>
				</div>
			</div>
		)
	}
}

export default App;
