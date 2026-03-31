import { RiAddLine, RiCloseLine } from 'react-icons/ri'
import clsx from 'clsx'
import { ItemSize, OrderItemInput } from '@/types/models'

interface ItemListInputProps {
  items: OrderItemInput[]
  onAddItem: () => void
  onRemoveItem: (index: number) => void
  onItemChange: (index: number, field: keyof OrderItemInput, value: string | number) => void
  error?: string
}

const SIZE_OPTIONS: { value: ItemSize; label: string }[] = [
  { value: 'small', label: 'Small' },
  { value: 'medium', label: 'Medium' },
  { value: 'large', label: 'Large' },
  { value: 'bulk', label: 'Bulk' }
]

export default function ItemListInput({
  items,
  onAddItem,
  onRemoveItem,
  onItemChange,
  error
}: ItemListInputProps) {
  return (
    <div className="space-y-3">
      <div className="flex items-center justify-between">
        <label className="block text-label-lg font-medium text-on-surface-variant">
          Items <span className="text-secondary">*</span>
        </label>
        <button
          type="button"
          onClick={onAddItem}
          disabled={items.length >= 20}
          className={clsx(
            'flex items-center gap-1 text-label-lg font-medium text-secondary',
            'touch-target hover:underline transition-opacity',
            items.length >= 20 && 'opacity-50 cursor-not-allowed'
          )}
        >
          <RiAddLine className="h-5 w-5" />
          Add Item
        </button>
      </div>

      <div className="space-y-3">
        {items.map((item, index) => (
          <div
            key={index}
            className="bg-surface-container-lowest rounded-md p-3 space-y-3"
          >
            {/* Item Header with Remove Button */}
            <div className="flex items-center justify-between">
              <span className="text-label-md font-medium text-on-surface-variant">
                Item {index + 1}
              </span>
              {items.length > 1 && (
                <button
                  type="button"
                  onClick={() => onRemoveItem(index)}
                  className="touch-target p-1 text-on-surface-variant hover:text-secondary transition-colors"
                  aria-label={`Remove item ${index + 1}`}
                >
                  <RiCloseLine className="h-5 w-5" />
                </button>
              )}
            </div>

            {/* Item Name */}
            <div>
              <label
                htmlFor={`item-name-${index}`}
                className="block text-label-md text-on-surface-variant mb-1"
              >
                Name
              </label>
              <input
                id={`item-name-${index}`}
                type="text"
                value={item.name}
                onChange={(e) => onItemChange(index, 'name', e.target.value)}
                className="input w-full text-body-lg"
                placeholder="e.g., Box of documents"
                required
                maxLength={100}
              />
            </div>

            {/* Quantity and Size Row */}
            <div className="grid grid-cols-2 gap-3">
              {/* Quantity */}
              <div>
                <label
                  htmlFor={`item-quantity-${index}`}
                  className="block text-label-md text-on-surface-variant mb-1"
                >
                  Quantity
                </label>
                <input
                  id={`item-quantity-${index}`}
                  type="number"
                  value={item.quantity}
                  onChange={(e) => onItemChange(index, 'quantity', parseInt(e.target.value) || 1)}
                  className="input w-full text-body-lg"
                  min={1}
                  max={999}
                  required
                />
              </div>

              {/* Size */}
              <div>
                <label
                  htmlFor={`item-size-${index}`}
                  className="block text-label-md text-on-surface-variant mb-1"
                >
                  Size
                </label>
                <select
                  id={`item-size-${index}`}
                  value={item.size}
                  onChange={(e) => onItemChange(index, 'size', e.target.value)}
                  className="input w-full text-body-lg"
                  required
                >
                  {SIZE_OPTIONS.map(option => (
                    <option key={option.value} value={option.value}>
                      {option.label}
                    </option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        ))}
      </div>

      {error && (
        <p className="text-label-md text-secondary" role="alert">
          {error}
        </p>
      )}

      {items.length >= 20 && (
        <p className="text-label-md text-on-surface-variant">
          Maximum 20 items reached
        </p>
      )}
    </div>
  )
}
