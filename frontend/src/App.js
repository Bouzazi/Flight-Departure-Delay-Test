import React, { useState, useEffect } from 'react';
import './index.css';
import DestinationAutocomplete from './components/DestinationAutocomplete';
import AirlinesMultiSelector from './components/AirlinesMultiSelector';
import FlightCard from './components/FlightCard';
import ToggleSwitch from './components/ToggleSwitch';
import axios from './utils/axios';
import { ArrowPathIcon } from '@heroicons/react/20/solid';

const App = () => {
  const [selectedDestination, setSelectedDestination] = useState(null);
  const [selectedAirlines, setSelectedAirlines] = useState([]);
  const [flights, setFlights] = useState([]);
  const [allFlightsMode, setAllFlightsMode] = useState(false);
  const [includeMarketingFlights, setIncludeMarketingFlights] = useState(false);
  const [questionableDelays, setQuestionableDelays] = useState(false);
  const [loading, setLoading] = useState(false); // State for loading animation

  useEffect(() => {
    const fetchFlights = async () => {
      try {
        if (allFlightsMode) {
          const response = await axios.get('/flights');
          setFlights(response.data);
        } else {
          if (selectedDestination && selectedAirlines.length > 0) {
            const params = {
              destination: selectedDestination.code,
              airlines: selectedAirlines.join(','),
            };
            if (includeMarketingFlights) {
              params.include_marketing_flights = true;
            }
            const response = await axios.get('/flights/search', { params });
            setFlights(response.data);
          } else {
            setFlights([]);
          }
        }
      } catch (error) {
        console.error('Error fetching flights:', error);
      }
    };

    fetchFlights();
  }, [selectedDestination, selectedAirlines, allFlightsMode, includeMarketingFlights]);

  const handleModeSwitch = (enabled) => {
    setAllFlightsMode(enabled);
    if (!enabled) {
      // Fetch flights with the current filters when switching back to false
      setSelectedDestination(selectedDestination);
      setSelectedAirlines(selectedAirlines);
    }
  };

  const handleRefreshClick = async () => {
    setLoading(true);
    try {
      await axios.get('/flights/fetch_flights');
    } catch (error) {
      console.error('Error refreshing flights:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 pb-8">
      <div className="mx-auto max-w-3xl">
        <div className="border-b flex justify-between border-gray-200 py-5 items-center">
          <div className='flex items-center space-x-2'>
            <h3 className="text-lg font-semibold leading-6 text-gray-900">
              Flight Departure Delay Search Test
            </h3>
            <ArrowPathIcon
              className={`h-5 w-5 text-gray-400 cursor-pointer ${loading ? 'animate-spin' : ''}`}
              onClick={handleRefreshClick}
            />
          </div>

          <div className="flex items-center space-x-4">
            <ToggleSwitch enabled={allFlightsMode} setEnabled={handleModeSwitch} label="Show all flights" />
            <ToggleSwitch enabled={questionableDelays} setEnabled={setQuestionableDelays} label="Questionable Delays" />
          </div>
        </div>
        {!allFlightsMode && (
          <>
            <DestinationAutocomplete onSelect={setSelectedDestination} />
            <AirlinesMultiSelector selectedAirlines={selectedAirlines} setSelectedAirlines={setSelectedAirlines} />
            <ToggleSwitch enabled={includeMarketingFlights} setEnabled={setIncludeMarketingFlights} label="Include marketing flights" />
            <div className='text-xs pb-3'>When enabled, the search will return flights for the specified destination even if the operating airline is not selected, as long as one of the marketing airlines is selected.</div>
          </>
        )}

        <hr></hr>

        {flights.length > 0 ? (
          <div className='mt-6'>
            <div className='my-4'>Showing <span className='font-bold'>{flights.length}</span> flights.</div>
            <div className="grid grid-cols-2 gap-6">
              {flights.map((flight) => (
                <FlightCard key={flight.id} flight={flight} questionableDelaysEnabled={questionableDelays} />
              ))}
            </div>
          </div>
        ) : (
          <div className='text-gray-500 text-center py-6'>
            Such emptiness...
          </div>
        )}
      </div>
    </div>
  );
};

export default App;
