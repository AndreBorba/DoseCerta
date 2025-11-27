const express = require("express");
const router = express.Router();
const controller = require("../controllers/examesController");

router.get("/exams", controller.listarExamesPorCPF);

module.exports = router;
