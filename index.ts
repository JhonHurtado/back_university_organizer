import app from "@/app";
import { ENV } from "@/config/config";

const server = app.listen(ENV.PORT, async () => {
  console.log(`🚀 Server running on http://localhost:${ENV.PORT}`);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, closing server gracefully");
  server.close(() => {
    console.log("Server closed");
    process.exit(0);
  });
});

process.on("unhandledRejection", (reason, promise) => {
  console.error("Unhandled Rejection at:", promise, "reason:", reason);
  process.exit(1);
});
