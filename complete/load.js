import http from "k6/http";
import { check, fail } from "k6";

export let options = {
  stages: [
    { duration: "30s", target: 1 },
    { duration: "60s", target: 5 },
    { duration: "90s", target: 10 },
  ]
};

export default function() {
    let res1 = http.get(`${__ENV.TARGET}`);

    check(res1, {
        "Status 200": (r) => r.status === 200
    });
};
