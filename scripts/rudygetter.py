#%%
import re, sqlalchemy, pandas as pd, datetime
#%%
'''
do insert(params: db_param.contents, into: 'experiment_info', 
			columns: ['name', 'runtime', 'data', 'lag_param', 'stream_const', 'step', 'starttime', 'endtime'], 
			values: [parameters['name'], "current_timestamp", 'bom', lag_param, stream_const, step, "'"+string(start)+"'::timestamp", "'"+string(end)+"'::timestamp"]
		);
		list get_index <- select(params: db_param.contents, select: 'SELECT index, name, runtime FROM experiment_info ORDER BY runtime DESC LIMIT 3');
		experiment_index <- int(get_index[2][0][0]);
		write 'experiment: ' + experiment_index;
		ask catchment[0].sub_catch {
			int catch_index <- catchment[0].sub_catch index_of self;
			myself.upload_strings[catch_index] <- '';
		}

string timestep <- "'"+string(current_date)+"'::timestamp";
		ask catchment[0].sub_catch {
			int catch_index <- catchment[0].sub_catch index_of self;
			ask myself {
				upload_strings[catch_index] <- upload_strings[catch_index] + 'INSERT INTO experiment_data 
			(index, timestep, catchment, rain_in, rain_buffer, storage, flow) VALUES 
			('+experiment_index+','+timestep+','+catch_index+','+-1+','+myself.rain_buffer+','+myself.storage+','+myself.out_flow/step+');';
//				do insert(params: db_param.contents, into: 'experiment_data',
//					columns: ['index', 'timestep', 'catchment', 'rain_in', 'rain_buffer', 'storage', 'flow'],
//					values: [experiment_index, timestep, catch_index, -1, myself.rain_buffer, myself.storage, myself.out_flow/step]
//				);
			}
		}
        '''
# %%
db = sqlalchemy.create_engine('postgres://floodaware:1234@localhost:5432')
conn = db.connect()
res = conn.execute('SELECT * FROM experiment_data')
print(res.fetchall())
# %%
# experiment_data = sqlalchemy.Table('experiment_data', sqlalchemy.MetaData(), autoload=True, autoload_with=db)
# %%
# sqlalchemy.select([experiment_data])
# %%
experiment_info = pd.DataFrame(columns=['name', 'runtime', 'data', 'lag_param', 'stream_const', 'step', 'starttime', 'endtime'], data=[['rudy0708_rout1', "'now()'", 'bom', '1.61', '0.6', '300', '20200207 0000', '20200209 0000']])
experiment_info.to_sql('experiment_info', db, if_exists='append', index=False)
#%%
res = conn.execute('SELECT index FROM experiment_info ORDER BY index DESC LIMIT 3')
results = res.fetchall()
experiment_index = results[0][0]
#%%
filename = '../data/UOW_Flash_Flood_REC_47_RG_Zero_New_Meta_AsCSV.csv'
file = open(filename, 'r')
data = file.read()
experiment_data = pd.DataFrame(columns=['index', 'timestep', 'catchment', 'rain_in', 'flow'])
sub_catches = re.findall(
    r'#####START_HYDROGRAPHS_Sub\d{1,3}\s{0,10}::1-Historic-Historic-Historic\(REC\)\n[^#]+\n',
    data    
)
for catch in sub_catches:
    catch_id = int(re.findall(r'#####START_HYDROGRAPHS_Sub(\d{1,3})', catch)[0]) - 1
    rows = re.findall(
        r'(.*?),(.*?),(?:.*?,){6}(.*?)\n',
        catch
    )
    # print(catch_id)
    dat = [[experiment_index, datetime.datetime(2020, 2, 7) + datetime.timedelta(minutes=float(timestep)), catch_id, (float(rain_in)/3600/1000)*300, flow] for timestep, rain_in, flow in rows]
    experiment_data = experiment_data.append(pd.DataFrame(dat, columns=['index', 'timestep', 'catchment', 'rain_in', 'flow']))

# %%
experiment_data.to_sql('experiment_data', db, index=False, if_exists='append')
# %%
