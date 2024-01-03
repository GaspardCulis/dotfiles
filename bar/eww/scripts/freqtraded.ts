#!/usr/bin/env bun

import http from "http";

const API_ADDRESS = "127.0.0.1";
const API_PORT = 42667;

type LoginResponse = {
  access_token: string;
  refresh_token: string;
};

type BotData = {
  url: string;
  auth: LoginResponse;
  summary: BotSummary;
};

type BotSummary = {
  name: string;
  dry_run: boolean;
  closed_profit: number;
  closed_profit_pct: number;
  open_profit: number;
  open_profit_pct: number;
};

let bots: BotData[] = [];

const URLS = JSON.parse(process.env.FREQTRADE_URLS);

async function login(
  url: string,
  user: string,
  pass: string,
): Promise<LoginResponse> {
  const response = await fetch(`${url}/api/v1/token/login`, {
    method: "POST",
    headers: {
      Authorization: "Basic " + btoa(`${user}:${pass}`),
      "Content-Type": "application/json",
    },
  });

  if (response.status !== 200) {
    throw Error("Failed to login");
  }

  return (await response.json()) as LoginResponse;
}

async function refresh_token(bot: BotData) {
  const response = await fetch(`${bot.url}/api/v1/token/refresh`, {
    method: "POST",
    headers: {
      Authorization: "Bearer " + bot.auth.refresh_token,
      "Content-Type": "application/json",
    },
  });

  if (response.status !== 200) {
    throw Error("Failed to login");
  }

  bot.auth.access_token = (await response.json()).access_token;
}

async function get_summary(
  url: string,
  auth: LoginResponse,
): Promise<BotSummary> {
  // Fetch config
  const config_response = await fetch(`${url}/api/v1/show_config`, {
    headers: {
      Authorization: "Bearer " + auth.access_token,
    },
  });

  if (config_response.status !== 200) {
    throw Error("Failed to get bot config");
  }

  const config = await config_response.json();

  // Fetch trades
  const trades_response = await fetch(`${url}/api/v1/status`, {
    headers: {
      Authorization: "Bearer " + auth.access_token,
    },
  });

  if (trades_response.status !== 200) {
    throw Error("Failed to get bot config");
  }

  const trades = await trades_response.json();

  // Fetch balance
  const profit_response = await fetch(`${url}/api/v1/profit`, {
    headers: {
      Authorization: "Bearer " + auth.access_token,
    },
  });

  if (profit_response.status !== 200) {
    throw Error("Failed to get bot config");
  }

  const profit = await profit_response.json();

  return {
    name: config.bot_name as string,
    dry_run: config.dry_run as boolean,
    open_profit: trades.length
      ? trades.map((v) => v.profit_abs).reduce((a, b) => a + b)
      : 0,
    open_profit_pct: trades.length
      ? trades.map((v) => v.profit_pct).reduce((a, b) => a + b) / trades.length
      : 0,
    closed_profit: profit.profit_closed_coin,
    closed_profit_pct: profit.profit_closed_percent,
  };
}

async function requestListener(
  req: http.IncomingMessage,
  res: http.ServerResponse,
) {
  switch (req.url) {
    case "/":
      res.writeHead(200);
      res.end("Welcome to the freqtrade API");
      break;
    case "/list":
      // Update bots
      await Promise.all(
        bots.map(async (bot) => {
          bot.summary = await get_summary(bot.url, bot.auth);
        }),
      );

      res.writeHead(200);
      res.setHeader("Content-Type", "application/json");
      res.end(JSON.stringify(bots.map((b) => b.summary)));
      break;
    default:
      let bot_name = req.url?.split("/")[1];

      let bot = bots.find((v) => v.summary.name == bot_name);

      if (bot) {
        let response = await fetch(
          `${bot.url}${req.url?.replace(`/${bot_name}`, "")}`,
          {
            headers: {
              Authorization: "Bearer " + bot.auth.access_token,
            },
          },
        );

        res.writeHead(response.status);
        res.end(await response.text());
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ error: "Resource not found" }));
      }
  }
}

async function daemon() {
  for (let url of URLS) {
    console.info("[INFO] Logging in for " + url);
    let auth = await login(
      url,
      process.env.FREQTRADE_USER!,
      process.env.FREQTRADE_PASS!,
    );

    let bot: BotData = {
      url,
      auth,
      summary: await get_summary(url, auth),
    };

    setInterval(
      async () => {
        console.info("[INFO] Refreshing token for " + url);
        await refresh_token(bot);
      },
      10 * (1 - (Math.random() - 0.5) / 4) * 60 * 1000,
    );

    bots.push(bot);
  }

  console.info("[INFO] Starting Web Server");

  const server = http.createServer(requestListener);
  server.listen(API_PORT, API_ADDRESS, () => {
    console.info(
      `[INFO] Web server running on http://${API_ADDRESS}:${API_PORT}`,
    );
  });
}

await daemon();
