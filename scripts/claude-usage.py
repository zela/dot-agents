#!/usr/bin/env python3
# Count Skill, slash-command, MCP and Agent use, and first-turn prompt size, from Claude Code transcripts.
#
# Usage:
#   claude-usage.py <days>   # window in days, for example 30
import json,os,glob,re,sys,collections,datetime as dt
root=os.path.expanduser('~/.claude/projects')
cut=dt.datetime.now(dt.timezone.utc)-dt.timedelta(days=int(sys.argv[1]))
skill=collections.Counter(); skill_days=collections.defaultdict(set)
cmd=collections.Counter(); mcp=collections.Counter(); mcp_days=collections.defaultdict(set)
agent=collections.Counter(); tools=collections.Counter()
sessions=set(); days=set(); first=[]
for f in glob.glob(root+'/**/*.jsonl',recursive=True):
    if os.path.getmtime(f)<cut.timestamp(): continue
    side='/subagents/' in f
    got_first=False
    for line in open(f,errors='ignore'):
        try: e=json.loads(line)
        except: continue
        ts=e.get('timestamp')
        if not ts: continue
        t=dt.datetime.fromisoformat(ts.replace('Z','+00:00'))
        if t<cut: continue
        d=t.date().isoformat()
        if not side: sessions.add(e.get('sessionId')); days.add(d)
        m=e.get('message') or {}
        c=m.get('content')
        if e.get('type')=='user':
            s=c if isinstance(c,str) else ' '.join(x.get('text','') for x in c if isinstance(x,dict) and x.get('type')=='text') if isinstance(c,list) else ''
            for x in re.findall(r'<command-name>/?([^<]+)</command-name>',s): cmd[x.strip()]+=1
        if e.get('type')=='assistant':
            u=m.get('usage') or {}
            if not got_first and not side and u and not e.get('isSidechain'):
                tot=u.get('input_tokens',0)+u.get('cache_creation_input_tokens',0)+u.get('cache_read_input_tokens',0)
                first.append((d,tot)); got_first=True
            if isinstance(c,list):
                for x in c:
                    if x.get('type')!='tool_use': continue
                    n=x.get('name',''); tools[n]+=1
                    if n=='Skill':
                        k=(x.get('input') or {}).get('skill','?'); skill[k]+=1; skill_days[k].add(d)
                    elif n.startswith('mcp__'):
                        srv=n.split('__')[1]; mcp[srv]+=1; mcp_days[srv].add(d)
                    elif n in('Agent','Task'):
                        agent[(x.get('input') or {}).get('subagent_type','general-purpose')]+=1
print('sessions',len(sessions),'active_days',len(days))
print('\n== Skill tool (count, distinct days)'); [print(f'{v:4} {len(skill_days[k]):3}d  {k}') for k,v in skill.most_common()]
print('\n== slash commands'); [print(f'{v:4}  {k}') for k,v in cmd.most_common(60)]
print('\n== MCP servers (calls, days)'); [print(f'{v:4} {len(mcp_days[k]):3}d  {k}') for k,v in mcp.most_common()]
print('\n== Agent types'); [print(f'{v:4}  {k}') for k,v in agent.most_common()]
first.sort()
import statistics
if first:
    v=[x[1] for x in first]; print('\n== first-turn prompt tokens: n',len(v),'median',statistics.median(v),'p10',sorted(v)[len(v)//10],'p90',sorted(v)[9*len(v)//10])
    for w in sorted(set(x[0][:7] for x in first)):
        vv=[x[1] for x in first if x[0][:7]==w]; print(' ',w,len(vv),statistics.median(vv))
