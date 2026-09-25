# Titanium proofs

This repository keeps the evidence records of titanium trial runs on
cella. Each record points to the trial directory and to the machine
books in it. The books are append-only files. The host writes them at
the time of each event. You can read each claim in this document
directly from the named file.

## Summary

Seven smoke runs on 2026-09-20 and 2026-09-21, all with
deepseek/deepseek-v4.1-flash. One redaction: the agent in
`agent/smoke-cella/2026-09-20__23-53-57/verify-cella-env-www__YpuaJtt`
printed its environment, which held an API key. That key reads
`sk-or-v1-REDACTED` in the six agent transcript files of that trial.
No other book was edited. Every trial completed; none errored or
retried. Each row's grade comes from the `result.json` in the named
run directory under `proofs/2026-09-21/`.

| Environment | Type | Run | Trials | Passed | Mean |
|---|---|---|---|---|---|
| cella | oracle | `oracle/smoke-cella/2026-09-21__02-34-46` | 4 | 3 | 0.75 |
| cella | oracle | `oracle/smoke-cella-integration/2026-09-20__23-49-10` | 4 | 4 | 1.00 |
| cella | agent | `agent/smoke-cella/2026-09-20__23-53-57` | 4 | 3 | 0.75 |
| gvisor | agent | `agent/smoke-gvisor/2026-09-20__13-18-54` | 3 | 3 | 1.00 |
| gvisor-podman | agent | `agent/smoke-gvisor-podman/2026-09-20__13-39-20` | 3 | 3 | 1.00 |
| krun-podman | agent | `agent/smoke-krun-podman/2026-09-20__13-52-58` | 4 | 4 | 1.00 |
| podman | agent | `agent/smoke-podman/2026-09-20__13-28-44` | 3 | 3 | 1.00 |

### Per task

#### cella, oracle

| Task | Trial | Reward |
|---|---|---|
| fix-git-offline | `fix-git-offline__H4PPGuS` | 1.0 |
| build-pmars | `build-pmars__UKsmkV9` | 0.0 |
| verify-cella-env-airgapped | `verify-cella-env-airgapped__wM5Bjwc` | 1.0 |
| verify-cella-env-www | `verify-cella-env-www__p5gMDhf` | 1.0 |

#### cella, oracle (integration)

| Task | Trial | Reward |
|---|---|---|
| cella-policy-engine-airgapped | `cella-policy-engine-airgapped__LDa9fng` | 1.0 |
| cella-policy-engine-www | `cella-policy-engine-www__TpWLAnM` | 1.0 |
| verify-cella-env-airgapped | `verify-cella-env-airgapped__RbRda9u` | 1.0 |
| verify-cella-env-www | `verify-cella-env-www__x8c8Tgb` | 1.0 |

#### cella, agent

| Task | Trial | Reward |
|---|---|---|
| fix-git-offline | `fix-git-offline__onz2W3R` | 1.0 |
| build-pmars | `build-pmars__njCdfxU` | 0.0 |
| verify-cella-env-airgapped | `verify-cella-env-airgapped__7fUom69` | 1.0 |
| verify-cella-env-www | `verify-cella-env-www__YpuaJtt` | 1.0 |

#### gvisor, agent

| Task | Trial | Reward |
|---|---|---|
| fix-git-offline | `fix-git-offline__qaGkyEE` | 1.0 |
| build-pmars | `build-pmars__7s52eyH` | 1.0 |
| verify-gvisor-env | `verify-gvisor-env__mpEp5zx` | 1.0 |

#### gvisor-podman, agent

| Task | Trial | Reward |
|---|---|---|
| fix-git-offline | `fix-git-offline__qBGdHyC` | 1.0 |
| build-pmars | `build-pmars__VGjSbvd` | 1.0 |
| verify-gvisor-podman-env | `verify-gvisor-podman-env__RF2VD4E` | 1.0 |

#### krun-podman, agent

| Task | Trial | Reward |
|---|---|---|
| fix-git-offline | `fix-git-offline__9sKniLr` | 1.0 |
| build-pmars | `build-pmars__biSwipd` | 1.0 |
| verify-krun-podman-env-airgapped | `verify-krun-podman-env-airgapped__P39yRYg` | 1.0 |
| verify-krun-podman-env-www | `verify-krun-podman-env-www__7S5eNAh` | 1.0 |

#### podman, agent

| Task | Trial | Reward |
|---|---|---|
| fix-git-offline | `fix-git-offline__LTYXowm` | 1.0 |
| build-pmars | `build-pmars__CvVdHkD` | 1.0 |
| verify-podman-env | `verify-podman-env__d99Sq3i` | 1.0 |

The two failures are both build-pmars on cella, one per task type.
They have different causes.

- The oracle failure is the case below. It is a policy sizing fault:
  keep_open ended at 3600 seconds, before the trial did, and the
  verifier's DNS lookups hit the stop window. The agent's solution
  was correct.
- The agent failure is the agent's own. The trial ran 406 seconds,
  well inside keep_open, and the verifier ran to completion: 2 of 4
  tests passed. The agent extracted the Debian source with
  `dpkg-source` into `/tmp/pmsrc/pmars-0.9.4`, then copied its
  contents flat into `/app` (`cp -a /tmp/pmsrc/pmars-0.9.4/. /app/`),
  so the build landed at `/app/src/pmars` instead of under
  `/app/pmars-0.9.4/`. The two tests that check for a source
  directory matching `/app/pmars-*` failed; the binary itself worked
  and ran headless. Books:
  `agent/smoke-cella/2026-09-20__23-53-57/build-pmars__njCdfxU/verifier/test-stdout.txt`
  and `agent/mini-swe-agent.txt` (line 1706) in the same trial.
  The appliance's `vmm.log` shows 16 parks, each released, none in
  the verifier window.

## Case: oracle/smoke-cella/2026-09-21__02-34-46/build-pmars__UKsmkV9

### The system under test

- A cella machine is a virtual machine with a membrane on its network
  device. The membrane holds each network crossing until a decision
  exists for it.
- A crossing with no standing permission causes a park. A park stops
  the machine. This is the one-shot rule: the machine cannot continue
  until a decision arrives.
- An external judge (the titanium engine) makes each decision. The
  judge is a different process, outside the machine.
- A standing permission (a membrane memory) lets a known crossing
  continue without a stop. Each permission has a time limit
  (keep_open). When the limit ends, the permission ends.
- The host writes four books for each machine: the process log
  (vmm.log), the network ledger, the audit book, and the
  membrane-memory file.

### What happened, as a timeline

All times are epoch seconds from the books. T+0 is the trial start.

| Time | T+ | Event |
|---|---|---|
| 1789994158 | 0 | The trial starts. The judge gives the appliance its standing permissions. Each permission has a time limit of 3600 seconds. |
| 1789994181 | 23 s | First stop: a boot-time crossing with no permission yet. The judge releases it. This is the design at work, not a fault. |
| 1789994181 - 1789997758 | 23 s - 1 h | The appliance serves 103,868 crossings with no stop. Each one has a "membrane released" line in the process log. |
| 1789997758 | 3600 s, exact | The permissions end, all in the same second, because the judge planted them all in the same second. |
| 1789997758 - 1789997771 | +0 - 13 s | Three stops. Each new crossing now has no permission. The membrane stops the machine on each one. The judge releases each crossing; the host restarts the machine. |
| 1789998272 - 1789998294 | +514 - 536 s | A second cluster of stops: the verifier's pytest bootstrap starts and opens new crossings. Each reply port re-earns its permission through one stop-decide-restart cycle (about 1.1 seconds each). |
| in this window | | The verifier asks the appliance to resolve pypi.org. The appliance is stopped. The resolver cannot answer. The verifier fails with "Temporary failure in name resolution". |
| 1789998294 | +536 s | The last permission is re-planted (port 50000, written 1789998294). The appliance serves without stops again. |

The verifier's failure was not a network fault. The membrane stopped
the machine, on schedule, because the permissions had ended. The books
show every step.

### How a stop becomes a DNS failure

The stop kills the query in one direction and the answer in the
other direction.

```mermaid
sequenceDiagram
    participant V as verifier resolver
    participant T as N.T.1 appliance translator (alive across freezes)
    participant A as N.M.1 appliance VM -- T.R.1 resolver inside
    participant J as W.E.1 the judge (via W.B.1 the bridge)

    Note over A: epoch 1789997758 -- keep_open ends.<br/>Every standing permission (N.F.7) expires<br/>in the same second, because the judge<br/>planted them all in the same second.
    A->>A: the next crossing finds no permission --<br/>park, one-shot FREEZE (vmm.log)

    rect rgb(200,210,235)
    Note over A: == MACHINE FROZEN ==<br/>vCPU does not run. T.R.1 does not run.<br/>No process inside exists in time.
    Note over V,T: attempt 1 -- the query dies at the edge
    V->>T: UDP query pypi.org -> 10.77.0.1:53
    T->>T: no VM attached -- discard the frame,<br/>count it (N.F.6 edge.log)
    Note over V: time limit ends -- attempt lost
    J->>A: release for the parked crossing
    end
    A->>A: THAW -- the machine runs again (audit: verb=thaw)

    Note over V,A: attempt 2 -- the answer dies at the membrane
    V->>T: UDP query, retry
    T->>A: frame delivered
    A->>A: T.R.1 computes the answer at once
    Note over A: the answer is an egress crossing to the<br/>reply port (T.W.1) -- its permission<br/>(N.F.7) has ended
    A->>A: park -- one-shot FREEZE again (vmm.log)

    rect rgb(200,210,235)
    Note over A: == MACHINE FROZEN ==<br/>the answer is held inside, unsent
    A->>J: parked entry (N.F.3 network/ledger)
    J->>A: release + new permission (the audit book, N.F.7)
    end
    A->>A: THAW, approximately 1.1 s after the park
    A-->>V: the answer, late
    Note over V: time limit already ended -- attempt lost

    Note over V: three attempts lost in the 22 s window --<br/>"Temporary failure in name resolution"
```

The query dies at the edge. The verifier's resolv.conf points at the
appliance (10.77.0.1:53). The process that answers DNS runs inside
the appliance guest. A stopped machine does not run its processes.
The resolver is not slow during a stop; it does not run at all. The
query frame still travels: verifier, then wire, then the appliance's
translator. The translator stays alive across a stop, by design. But
no virtual machine is attached to it during the stop, and the rule
for that state is: discard the frame and count it. The count is in
the file `edge.log`. The query is lost. To the sender this looks the
same as packet loss, and UDP DNS retries against exactly that.

The answer dies at the membrane. When a retry arrives in a gap
between stops, the resolver runs and computes the answer at once.
The answer is a new egress crossing to the verifier's reply port. At
that time, the permission for that crossing had ended. The act of
answering is thus itself the cause of the next stop: the freeze
lines in `vmm.log` name egress to 10.77.0.2 ports 50000 through
50004, protocol 17 -- these are DNS answers. The membrane holds the
answer with the machine. The answer leaves only after the decision
and the restart, approximately 1.1 seconds later. The resolver's
per-query time limit is shorter than that. The verifier counts the
attempt as lost.

Then the retry budget ends. The resolver makes three attempts. The
stop-and-repark window spans approximately 22 seconds: eight reply
ports each re-earn a permission through one stop cycle, and each
stop also holds all other traffic that is in flight at that moment.
Three retries inside that window all fail, by one mechanism or the
other. The resolver returns "Temporary failure in name resolution".
The tool uv stops its fetch of pypi.org. The pytest bootstrap exits
with an error. The verifier grades the run as failed. The agent's
solution was already correct; the grader's own network use hit the
window.

### Suggested resolution

The containment needs no change. The policy sizing does.

1. Make keep_open longer than the trial. The trial budget is 5580
   seconds. The permissions ended at 3600 seconds. A permission that
   ends before the trial ends is a scheduled brownout. Set keep_open
   to the trial budget plus a margin.
2. As an alternative: plant the permissions again before they end.
   The engine already plants them at stream open. Plant them again on
   a timer, for example at each half of keep_open. This uses the
   existing seam. It needs no change to cella. It also spreads the
   end times, so one shared cliff cannot occur again.
3. Do not ask for elastic permissions. A permission that extends
   itself on use has no fixed end, and no one can then say when it
   stands and when it does not. The judge said 3600 seconds and the
   membrane kept that word. The error was in the number, not in the
   keeping.

### The evidence, one crossing end to end

The books that follow are for the reply crossing to port 50000. All
paths start at:

`proofs/2026-09-21/oracle/smoke-cella/2026-09-21__02-34-46/build-pmars__UKsmkV9/cella-chronicle/build-pmars-uksmkv9-appliance/`

1. **The park and the stop.** File `vmm.log`, lines 243032 and
   243033. The machine parked an egress frame to 10.77.0.2:50000 at
   host_ns 1789998294173654712. The machine stopped 24 microseconds
   later.
2. **The park in the ledger.** File `network/ledger` (render it with
   `cella --dump`). Entry id 0000003e01a776fc8d3e5897da586d87, same
   host_ns.
3. **The decision, the new permission, and the restart.** File
   `audit` (rendered copy: `audit.txt`). The judge released the entry
   at host_ns 1789998294199193765. The judge planted a new permission
   for 10.77.0.2:50000/17 at host_ns 1789998294211286321. The host
   thawed the machine at host_ns 1789998295264878311. The machine was
   stopped for approximately 1.1 seconds.
4. **The new permission on file.** File `membrane-memory` (rendered
   copy: `membrane-memory.txt`). Row: port 50000, keep_open 3600,
   written 1789998294.

The four books agree to the microsecond because each book carries the
same host clock (host_ns).

### What this case shows

- The machine could not make an unsanctioned crossing. The stop
  happened before the frame left the machine, not after.
- The stop was not a courtesy. The virtual machine did not run at all
  until the decision arrived. A stopped machine cannot try again,
  cannot use a different path, and cannot hide an action.
- The decision came from outside the machine. The machine had no way
  to give itself permission.
- Every event is on the record with a timestamp: the park, the stop,
  the decision, the new permission, the restart. The operator's own
  actions are in the same books as the machine's actions.
- The cost of the design is visible and honest: when permissions end,
  service stops. The fix for this trial is a policy sizing change
  (make keep_open longer than the trial), not a change to the
  containment.

The failure mode of this system is a stopped machine and a full set
of books. That is the point of this record.
