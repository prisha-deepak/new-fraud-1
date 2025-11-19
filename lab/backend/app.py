from flask import Flask, jsonify, request
from models import GraphDatabase, GNN
import os

app = Flask(__name__)

# ---------------------- ROUTES --------------------------

@app.route("/")
def home():
    return open("lab/frontend/index.html").read()


@app.route("/accounts")
def get_accounts():
    accounts = graph_database.get_accounts()
    return jsonify(accounts)


@app.route("/transactions")
def get_transactions(sender_id=None, receiver_id=None):
    sender_id = request.args.get("sender_id")
    receiver_id = request.args.get("receiver_id")

    if sender_id is None and receiver_id is None:
        return "Please provide sender_id or receiver_id as query parameter", 400

    transactions = graph_database.get_transactions(
        filters={"sender_id": sender_id, "receiver_id": receiver_id}
    )
    return jsonify(transactions)


@app.route("/transactions/new", methods=["POST"])
def get_transactions_by_sender_receiver():
    payload = request.get_json()
    sender_id = payload["sender_id"]
    receiver_id = payload["receiver_id"]
    total_amount = payload["total_amount"]

    try:
        graph = graph_database.graph
        graph_database.create_new_transaction(sender_id, receiver_id, total_amount)

        predictions = gnn_model.predict(graph)

        node_list = list(graph.nodes)
        node_indices = {node: idx for idx, node in enumerate(node_list)}

        node_a_ix = node_indices[str(sender_id)]
        node_b_ix = node_indices[str(receiver_id)]

        a_fraud = float(predictions.flatten()[node_a_ix])
        b_fraud = float(predictions.flatten()[node_b_ix])

        return jsonify(
            {
                "nodes": {"sender": a_fraud, "receiver": b_fraud},
                "is_fraud": bool(a_fraud > 0.5 or b_fraud > 0.5),
            }
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 400


@app.route("/graphml")
def get_graphml():
    return graph_database.get_graphml()

# ---------------------- MODEL LOAD (must be BEFORE run) --------------------------

graph_database = GraphDatabase()
gnn_model = GNN(graph_database.graph)

# ---------------------- FLASK SERVER --------------------------

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)

