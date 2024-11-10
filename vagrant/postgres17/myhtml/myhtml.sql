-- ################################################################################
create or replace function myhtml (
	h1name varchar, 
	h1desc varchar, 
	h2nameA varchar[], 
	h2descA varchar[], 
	h3infoA varchar[],
	p_color integer,
	p_theme integer ) 
returns text as 
$$
declare
s text:=null;
d text:='DEBUG is ON';
v_debug boolean:=false;
h2ref_factor integer:=1000000;
h3ref_factor integer:=10000;
h2ref integer;
h3ref integer;
v_h3_tokens varchar[];
v_h3_token_name varchar;
v_h3_token_sql varchar;

a_fg varchar[]; -- theme foreground colors
c_fg varchar; -- foreground colors
c_bg varchar; -- background colors

v_newline varchar:=chr(10)||'\echo ';
v_color integer:=3;
v_theme integer:=p_theme;
a_color varchar[]:= ARRAY  [
--1.blue   2.green     3.red 4.Magenta  5.purple 
'#00008B','#008000','#FF0000','#C21E56','#800020', 	-- p_theme=0 dark colors
'#0047AB','#4F7942','#FF2400','#E30B5C','#9F2B68', 	-- p_theme=1 normal colors
'#6495ED','#90EE90','#FF4433','#FF4433','#BF40BF',		-- p_theme=2 light colors
'#A7C7E7','#AFE1AF','#FAA0A0','#FAA0A0','#E0B0FF'		-- p_theme=3 for dark theme
];

begin

-- default to theme 1 for invalid p_theme input
if (p_theme <0 or p_theme >3) then
	raise notice 'Valid Themes: 1=Dark 2=Medium 3=Light 4=DarkBackground';
	v_theme:=1;
end if;

-- default to random color 1 for invalid p_color input
if (p_color <1 or p_color >5) then
	raise notice 'Valid Colors: 1=Blue 2=Green 3=Red 4=Magenta 5=Purple 0=Random';
	v_color:=0;
end if;

if (p_theme=3) then -- black background
	c_fg:='White';
	c_bg:='Black';
else
	c_fg:='Black';
	c_bg:='White';
end if;

-- assign h1/h2/h3 html colors based on color and theme inputs
case 
when (v_color = 0) then
	v_color:=(floor(random()*(5-1+1)+1)::int)+(v_theme*5);
	a_fg:=ARRAY [ a_color[v_color],a_color[v_color],a_color[v_color],a_color[v_color],a_color[v_color]];
   
-- red
else
	v_color:=p_color+v_theme*5;
	a_fg:=ARRAY [ a_color[v_color],a_color[v_color],a_color[v_color],a_color[v_color],a_color[v_color]];
end case;

-- check array sizes match
if (array_upper(h2nameA, 1)!=array_upper(h2descA, 1)) then
	raise notice 'array lengths of h2nameA and h2descA did not match';
end if;

-- check array sizes match
if (array_upper(h2nameA, 1)!=array_upper(h3infoA, 1)) then
	raise notice 'array lengths of h2nameA and h3infoA did not match';
end if;

if (v_debug) then
	d:=d||chr(10)||'DEBUG: h1name='||h1name;
	d:=d||chr(10)||'DEBUG: '||repeat('- ',30);
end if;

-- prepare html header info with h1/h2/h3/h4 colors
s:=v_newline||'\t off';
s:=s||v_newline||'<html><head>';
s:=s||v_newline||'<title>'||h1name||'</title>';
s:=s||v_newline||'<style type="text/css">';
s:=s||v_newline||'body {font:10pt Arial; color:'||c_fg||'; background:'||c_bg||';}';

s:=s||v_newline||'p {font:9pt Arial; color:Gray; background:'||c_bg||';}';

s:=s||v_newline||'h1 {font:bold 20pt Arial; color:'||a_fg[1]||'; background:'||c_bg||'; border-bottom:3px solid '||a_fg[1]||'; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}';

s:=s||v_newline||'h2 {font:bold 14pt Arial; color:'||a_fg[2]||'; background:'||c_bg||'; border-top:2px solid '||a_fg[2]||'; margin-top:4pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}';

s:=s||v_newline||'h3 {font:bold 10pt Arial; color:'||a_fg[3]||'; background:'||c_bg||'; border-top:1px dotted #cccc99; margin-top:4pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}';

s:=s||v_newline||'h4 {font:bold 9pt Arial; color:'||a_fg[4]||'; background:'||c_bg||'; ; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;}';

s:=s||v_newline||'th {font:10pt Arial; color:'||c_bg||'; background:'||a_fg[5]||'; border-bottom:2px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:2px 2px 2px 0px;}';

s:=s||v_newline||'td {font:10pt Arial; color:'||'Black'||'; background:#F0F0F5; vertical-align:top;}';

s:=s||v_newline||'a {font:10pt Arial; color:'||c_fg||'; background:'||c_bg||'; horizontal-align:right; vertical-align:top; margin-top:0pt; margin-bottom:0pt;}';

s:=s||v_newline||'table.tdiff { border_collapse: collapse; }';

s:=s||v_newline||'</style></head><body>';
s:=s||v_newline||'<a name="title"></a><h1>'||h1name||'</h1>';
s:=s||v_newline||'<p>'||h1desc||'</p>';
s:=s||v_newline||'<a name="index"></a><h2>INDEX</h2>' ;


-- add h2 links
for i in array_lower(h2nameA, 1)..array_upper(h2nameA, 1) loop
	h2ref:=i*h2ref_factor;
	s:=s||v_newline||'<a href="#'||h2ref||'">'||i||'. '||replace(h2nameA[i],'_',' ')||'</a>';
	v_h3_tokens:=string_to_array(h3infoA[i],',');
	for j in array_lower(v_h3_tokens, 1)..array_upper(v_h3_tokens, 1) loop
		h3ref:=h3ref_factor+i*h2ref_factor+j*h3ref_factor;	
		s:=s||v_newline||'<a href="#'||h3ref||'">'||j||'</a>';
	end loop;
	s:=s||v_newline||'<br>';
end loop;
s:=s||v_newline||'<a href="#end">End</a><br>';

-- add h2 details
for i in array_lower(h2nameA, 1)..array_upper(h2nameA, 1) loop
	h2ref:=i*h2ref_factor;
	s:=s||v_newline||'<a name="'||h2ref||'"></a>';
	s:=s||v_newline||'<h2>'||i||'.'||h2nameA[i]||'</h2>';
	--s:=s||v_newline||'<a href="#title">^Top</a>';
	s:=s||v_newline||'<h4> Description: <p>'||replace(h2descA[i],'_',' ')||'</p></h4>';
	
	if (v_debug) then
	d:=d||chr(10)||'DEBUG: h2_ref='||h2ref||' h2nameA['||i||']='||h2nameA[i];
	d:=d||chr(10)||'DEBUG: h2desc['||i||']='||h2descA[i];
	end if;

	if (v_debug) then
	d:=d||chr(10)||'DEBUG: h3info['||i||']='||h3infoA[i] ;
	end if;

	v_h3_tokens:=string_to_array(h3infoA[i],',');

	-- add h3 details
	for j in array_lower(v_h3_tokens, 1)..array_upper(v_h3_tokens, 1) loop
		h3ref:=h3ref_factor+i*h2ref_factor+j*h3ref_factor;	
		v_h3_token_name:=left(v_h3_tokens[j],position(':' in v_h3_tokens[j])-1);
		v_h3_token_sql:=substr(v_h3_tokens[j],position(':' in v_h3_tokens[j])+1);

		if (v_debug) then
			d:=d||chr(10)||'DEBUG: h3_ref='||h3ref||' h3_tokens['||j||']='||v_h3_tokens[j];
			d:=d||chr(10)||'DEBUG: h3_name='||v_h3_token_name||' h3_sql='||v_h3_token_sql;
		end if;

		s:=s||v_newline||'<a name="'||h3ref||'"></a><br>';
		s:=s||v_newline||'<h3>'||i||'.'||j||' '||h2nameA[i]||' :: '||replace(v_h3_token_name,'_',' ')||'</h3><br>';
	
		s:=s||v_newline||'<a>GoTo:</a> ';
		s:=s||v_newline||'<a href="#title">^Top</a> ';
		s:=s||v_newline||'<a href="#'||h2ref||'">^'||h2nameA[i]||'</a> ';
		s:=s||v_newline||'<a href="#'||h3ref-h3ref_factor||'">Previous'||'</a> ';
		s:=s||v_newline||'<a href="#'||h3ref+h3ref_factor||'">Next'||'</a> ';
		s:=s||v_newline||'<a href="#end">End</a>';
		s:=s||'<br>';
		s:=s||chr(10)||'\t off';
		s:=s||chr(10)||'\H';
	-- to use href for result rows from a sql :  <a href="#1030000"><h4>5</h4></a>
		s:=s||chr(10)||'select * from '||v_h3_token_sql||';';
		s:=s||chr(10)||'\H ';
		s:=s||chr(10)||'\t on ';

	end loop; --j
	if (v_debug) then
		d:=d||chr(10)||'DEBUG: '||repeat('- ',30);
	end if;
end loop; --i

-- add footers
s:=s||v_newline||'</body></html><br>' ;
s:=s||v_newline||'<a href="#title">^Top</a><br>';
s:=s||v_newline||'<a name="End"></a><br>';
s:=s||v_newline||'<p>*** End of Report ***</p>';
s:=s||v_newline||'<p> Color:'||v_color||' Theme:'||v_theme||'</p>';
s:=s||v_newline||'<p>&#169; Copyright of RAODB Reports Library Extension</p>';

if (v_debug) then
	return d;
else
	return s;
end if;

end;
$$
language plpgsql;
-- ################################################################################
