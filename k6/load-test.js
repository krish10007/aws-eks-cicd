import http from 'k6/http';
import { check, sleep } from 'k6';

// Test configuration
export const options = {
    stages: [
      { duration: '2m', target: 50 },
      { duration: '3m', target: 50 },
      { duration: '2m', target: 0 },
    ],
    thresholds: {
      http_req_duration: ['p(95)<500'],
      http_req_failed: ['rate<0.01'],
    },
  };
const ALB_URL = 'http://k8s-prod-fastapia-7c34bafd55-2041976011.us-east-1.elb.amazonaws.com';

export default function () {
  // Hit the root endpoint — this does real work (hostname lookup, time calculation)
  const res = http.get(`${ALB_URL}/`);
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response has hostname': (r) => JSON.parse(r.body).hostname !== undefined,
  });

  sleep(0.1);  // 100ms pause between requests per virtual user
}