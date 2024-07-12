import React, { useEffect, useState } from 'react';
import axios from '../utils/axios';

export default function AirlinesMultiSelector({ selectedAirlines, setSelectedAirlines }) {
    const [airlines, setAirlines] = useState([]);

    useEffect(() => {
        const fetchAirlines = async () => {
            try {
                const response = await axios.get('/airlines');
                setAirlines(response.data);
            } catch (error) {
                console.error('Error fetching airlines:', error);
            }
        };

        fetchAirlines();
    }, []);

    const handleCheckboxChange = (id) => {
        setSelectedAirlines((prevSelected) =>
            prevSelected.includes(id)
                ? prevSelected.filter((airlineId) => airlineId !== id)
                : [...prevSelected, id]
        );
    };

    const handleSelectAll = () => {
        setSelectedAirlines(airlines.map(airline => airline.code));
    };

    const handleDeselectAll = () => {
        setSelectedAirlines([]);
    };

    return (
        <fieldset>
            <legend className="w-full flex items-center justify-between">
                <div className='text-base font-semibold leading-6 text-gray-900'>Airlines</div>
                <div className="flex space-x-1">
                    <button
                        type="button"
                        className="rounded bg-white px-2 py-1 text-xs font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={handleSelectAll}
                    >
                        Select All
                    </button>
                    <button
                        type="button"
                        className="rounded bg-white px-2 py-1 text-xs font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={handleDeselectAll}
                    >
                        Deselect All
                    </button>
                </div>
            </legend>
            <div className="flex flex-wrap mt-4 divide-y divide-gray-200 border-b border-t border-gray-200">
                {airlines.map((airline) => (
                    <div key={airline.code} className="relative flex items-center py-3 mx-2">
                        <div className="min-w-0 flex-1 text-sm">
                            <label htmlFor={`airline-${airline.code}`} className="select-none font-medium text-gray-900">
                                {airline.label}<span className='ml-1 text-xs font-bold'>{`(${airline.code})`}</span>
                            </label>
                        </div>
                        <div className="ml-3 flex h-6 items-center">
                            <input
                                id={`airline-${airline.code}`}
                                name={`airline-${airline.code}`}
                                type="checkbox"
                                className="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-600"
                                checked={selectedAirlines.includes(airline.code)}
                                onChange={() => handleCheckboxChange(airline.code)}
                            />
                        </div>
                    </div>
                ))}
            </div>
        </fieldset>
    );
}
