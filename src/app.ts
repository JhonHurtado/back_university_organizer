import express from "express";
import dotenv from "dotenv";
import session from "express-session";
import morgan from "morgan";
import passport from "@/config/auth/passport";
import { sessionConfig } from "@/config/session";
import { corsConfig, helmetConfig, limiter } from "@/config/security";
import routes from "@/routes/index.routes";
import { autoLogActivity } from "@/middleware/activityLog/activityLog.middleware";

dotenv.config();

const app = express();

app.set("trust proxy", 1);

app.disable("x-powered-by");

// Security middleware (apply first)
app.use(helmetConfig);
app.use(corsConfig);
app.use(limiter);

// Body parsing
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Logging
app.use(morgan(process.env.NODE_ENV === "production" ? "combined" : "dev"));

// Session & Auth
app.use(session(sessionConfig));
app.use(passport.initialize());
app.use(passport.session());

// Activity Logging (after auth, before routes)
app.use(autoLogActivity());

// Health check
app.get("/health", (_, res) => res.status(200).json({ status: "ok" }));
app.use("/api/v1", routes);

// 404 handler
app.use((_, res) => {
  res.status(404).json({ error: "Route not found" });
});

export default app;
