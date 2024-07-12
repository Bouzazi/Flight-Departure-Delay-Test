import { useState, useEffect } from 'react';
import { CheckIcon, ChevronUpDownIcon } from '@heroicons/react/20/solid';
import { Combobox, ComboboxInput, ComboboxOptions, ComboboxButton, ComboboxOption, Label } from '@headlessui/react';
import axios from '../utils/axios';
import { useDebounce } from '../hooks/useDebounce';

function classNames(...classes) {
    return classes.filter(Boolean).join(' ');
}

export default function DestinationAutocomplete({ onSelect }) {
    const [query, setQuery] = useState('');
    const [destinations, setDestinations] = useState([]);
    const debouncedQuery = useDebounce(query, 300); // 300ms debounce

    useEffect(() => {
        const fetchDestinations = async () => {
            if (debouncedQuery === '') {
                setDestinations([]);
                return;
            }
            try {
                const response = await axios.get(`/airports`, {
                    params: { search: debouncedQuery }
                });
                setDestinations(response.data);
            } catch (error) {
                console.error('Error fetching destinations:', error);
            }
        };

        fetchDestinations();
    }, [debouncedQuery]);

    return (
        <Combobox as="div" onChange={onSelect} className={'py-5'}>
            <Label className="block text-sm font-medium leading-6 text-gray-900">Destination</Label>
            <div className="relative mt-2">
                <ComboboxInput
                    className="w-full rounded-md border-0 bg-white py-1.5 pl-3 pr-12 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
                    onChange={(event) => setQuery(event.target.value)}
                    displayValue={(destination) => destination?.label || ''}
                    placeholder="Search by code or label (e.g., 'FRA' or 'Frankfurt Airport')"
                />
                <ComboboxButton className="absolute inset-y-0 right-0 flex items-center rounded-r-md px-2 focus:outline-none">
                    <ChevronUpDownIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
                </ComboboxButton>

                {destinations.length > 0 && (
                    <ComboboxOptions className="absolute z-10 mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none sm:text-sm">
                        {destinations.map((destination) => (
                            <ComboboxOption
                                key={destination.code}
                                value={destination}
                                className={({ active }) =>
                                    classNames(
                                        'relative cursor-default select-none py-2 pl-3 pr-9',
                                        active ? 'bg-indigo-600 text-white' : 'text-gray-900'
                                    )
                                }
                            >
                                {({ active, selected }) => (
                                    <>
                                        <div className="flex items-center">
                                            <span className={classNames('truncate', selected && 'font-semibold')}>{destination.label}</span>
                                            <span
                                                className={classNames(
                                                    'ml-2 truncate text-xs font-bold text-gray-500',
                                                    active ? 'text-indigo-200' : 'text-gray-500'
                                                )}
                                            >
                                                {destination.code}
                                            </span>
                                        </div>

                                        {selected && (
                                            <span
                                                className={classNames(
                                                    'absolute inset-y-0 right-0 flex items-center pr-4',
                                                    active ? 'text-white' : 'text-indigo-600'
                                                )}
                                            >
                                                <CheckIcon className="h-5 w-5" aria-hidden="true" />
                                            </span>
                                        )}
                                    </>
                                )}
                            </ComboboxOption>
                        ))}
                    </ComboboxOptions>
                )}
            </div>
        </Combobox>
    );
}
