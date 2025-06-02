import http from 'k6/http';
import { check } from 'k6';
import { Counter } from 'k6/metrics';

export const options = {
  scenarios: {
    direct_test: {
      executor: 'constant-vus',
      vus: 10,
      duration: '10s',
      exec: 'direct',
    },
    bandwidthLimit_test: {
      executor: 'constant-vus',
      vus: 10,
      duration: '10s',
      exec: 'bandwidthLimit',
    },
  },
};

const NODE_IP = __ENV.NODE_IP;

const directCounter = new Counter('Direct');
const limitedCounter = new Counter('Limited');

export function direct() {
  let res1 = http.get(`http://${NODE_IP}:30000/`, {
    tags: { name: 'Direct' },
  });
  directCounter.add(1);
  check(res1, { 'Direct status is 200': (r) => r.status === 200 });
}

export function bandwidthLimit() {
  let res2 = http.get(`http://${NODE_IP}:30005/`, {
    tags: { name: 'Limited' },
  });
  limitedCounter.add(1);
  check(res2, { 'With Bandwidth Limit status is 200': (r) => r.status === 200 });
}
