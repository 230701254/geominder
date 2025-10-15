const express = require('express');
const { MongoClient, ServerApiVersion, ObjectId } = require('mongodb'); // Import ObjectId here
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json()); // Allows your API to understand JSON

// --- IMPORTANT ---
// PASTE YOUR WORKING MONGODB ATLAS CONNECTION STRING HERE
const uri = "mongodb+srv://my_app_user:testpassword123@cluster0.ucurzho.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

// Create a MongoClient with a MongoClientOptions object to set the Stable API version
const client = new MongoClient(uri, {
  serverApi: {
    version: ServerApiVersion.v1,
    strict: true,
    deprecationErrors: true,
  }
});

let remindersCollection;

async function connectDB() {
  try {
    // Connect the client to the server
    await client.connect();
    
    // Send a ping to confirm a successful connection
    await client.db("admin").command({ ping: 1 });
    console.log("✅ Pinged your deployment. You successfully connected to MongoDB!");

    const database = client.db('geominder');
    remindersCollection = database.collection('reminders');

  } catch(e) {
    console.error("❌ Could not connect to MongoDB Atlas", e);
    // If connection fails, we should exit the process
    process.exit(1);
  }
}

// --- API ENDPOINTS ---

// CREATE a new reminder
app.post('/reminders', async (req, res) => {
  try {
    const reminder = req.body;
    reminder.createdAt = new Date();
    const result = await remindersCollection.insertOne(reminder);
    res.status(201).send(result);
  } catch (e) {
    res.status(500).send({ message: "Failed to create reminder", error: e });
  }
});

// READ all reminders for a specific user
app.get('/reminders/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const reminders = await remindersCollection.find({ userId: userId }).toArray();
    res.status(200).send(reminders);
  } catch (e) {
    res.status(500).send({ message: "Failed to fetch reminders", error: e });
  }
});

// UPDATE an existing reminder
app.put('/reminders/:id', async (req, res) => {
  try {
    const reminderId = req.params.id;
    const updatedData = req.body;
    
    // Remove the _id from the update data to avoid errors
    delete updatedData._id;

    const result = await remindersCollection.updateOne(
      { _id: new ObjectId(reminderId) },
      { $set: updatedData }
    );
    res.status(200).send(result);
  } catch (e) {
    res.status(500).send({ message: "Failed to update reminder", error: e });
  }
});

// DELETE a reminder
app.delete('/reminders/:id', async (req, res) => {
  try {
    const reminderId = req.params.id;
    const result = await remindersCollection.deleteOne({ _id: new ObjectId(reminderId) });
    res.status(200).send(result);
  } catch (e) {
    res.status(500).send({ message: "Failed to delete reminder", error: e });
  }
});


// --- START THE SERVER ---
const port = 3000;
app.listen(port, () => {
  console.log(`🚀 Server is running on http://localhost:${port}`);
  // Connect to the database when the server starts
  connectDB();
});